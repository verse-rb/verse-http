# frozen_string_literal: true

module Verse
  module Http
    module Spec
      module HttpHelper
        attr_reader :current_auth_context

        def app
          Verse::Http::Server
        end

        def current_auth_token
          return nil unless current_auth_context

          user = {
            user_data: current_auth_context.metadata,
            role: current_auth_context.role,
            scopes: current_auth_context.custom_scopes
          }

          Verse::Http::Auth::Token.encode(
            *user.values_at(:user_data, :role, :scopes),
            exp: Time.now.to_i + 1_000_000
          )
        end

        %i[get put patch post delete].each do |method|
          define_method(method) do |path, params = {}, headers = {}|
            Verse::Auth::CheckAuthenticationHandler.disable do
              if current_auth_context
                headers[Verse::Http::Auth.auth_header] ||= "Bearer #{current_auth_token}"
              end

              unflavored_method = Rack::Test::Methods.instance_method(method).bind(self)

              deep_check_multipart = ->(hash) {
                hash.any? do |k, v|
                  if v.is_a?(Hash)
                    return true if deep_check_multipart.call(v)
                  elsif v.is_a?(Array)
                    return true if v.any? { |e| e.is_a?(Hash) && deep_check_multipart.call(e) }
                  elsif v.is_a?(Rack::Test::UploadedFile)
                    return true
                  end
                end

                return false
              }

              if params.is_a?(Hash) && params.any?
                is_multipart = deep_check_multipart.call(params)

                if is_multipart
                  headers["CONTENT_TYPE"] ||= "multipart/form-data"
                else
                  headers["CONTENT_TYPE"] ||= "application/json"

                  if headers["CONTENT_TYPE"] == "application/json"
                    params = params.to_json
                  end
                end
              end

              unflavored_method.call(path, params, headers)
            end
          end
        end
      end
    end
  end
end
