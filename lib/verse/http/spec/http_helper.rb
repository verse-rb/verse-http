# frozen_string_literal: true

module Verse
  module Http
    module Spec
      module HttpHelper
        class << self
          attr_accessor :current_user

          # Generate a new token for the given user.
          # @param username [String] The name of the user. Must be registered via `add_user` method
          # @return [String] The JWT token.
          def new_token(username)
            user = Verse::Spec.users.fetch(username.to_sym) {
              raise "User `#{username}` not found. " \
                    "Add it with `Verse::Http::Spec::HttpHelper.add_user(\"#{username}\", role, metadata, scopes)`" \
                    "in your spec_helper.rb"
            }

            Verse::Http::Auth::Token.encode(
              *user.values_at(:user_data, :role, :scopes),
              exp: Time.now.to_i + 1_000_000
            )
          end
        end

        def current_user
          Verse::Http::Spec::HttpHelper.current_user
        end

        def current_user=(username)
          Verse::Http::Spec::HttpHelper.current_user = username
        end

        def app
          Verse::Http::Server
        end

        def as_user(username)
          old_user = Verse::Http::Spec::HttpHelper.current_user
          Verse::Http::Spec::HttpHelper.current_user = username
          yield
        ensure
          Verse::Http::Spec::HttpHelper.current_user = old_user
        end

        def current_user_context
          current_user = Verse::Http::Spec::HttpHelper.current_user
          return nil if current_user.nil?

          params = Verse::Spec.users.fetch(current_user) {
            raise "user `#{current_user}` not found. Please add it with Verse::Spec.add_user"
          }

          Verse::Auth::Context.from_role(
            params[:role],
            custom_scopes: params[:scopes],
            metadata: params[:user_data]
          )
        end

        %i[get put patch post delete].each do |method|
          define_method(method) do |path, params = {}, headers = {}|
            Verse::Auth::CheckAuthenticationHandler.disable do
              if Verse::Http::Spec::HttpHelper.current_user
                headers[Verse::Http::Auth.auth_header] ||= "Bearer #{Verse::Http::Spec::HttpHelper.new_token(current_user)}"
              end

              unflavored_method = Rack::Test::Methods.instance_method(method).bind(self)
              unflavored_method.call(path, params, headers)
            end
          end
        end
      end
    end
  end
end
