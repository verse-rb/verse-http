# frozen_string_literal: true

module Verse
  module Http
    module Spec
      module HttpHelper
        class << self
          attr_accessor :current_user

          # Add a user to the helper.
          # @param name [String] The name of the user.
          # @param role [String] The role of the user.
          # @param metadata [Hash] The metadata of the user.
          # @param scopes [Hash] The scopes of the user.
          def add_user(name, role, metadata = nil, scopes = {})
            metadata ||= { id: 1, name: name }
            @users ||= {}
            @users[name.to_sym] = { role: role, metadata: metadata, scopes: scopes }
          end

          # Generate a new token for the given user.
          # @param username [String] The name of the user. Must be registered via `add_user` method
          # @return [String] The JWT token.
          def new_token(username)
            @users ||= {}
            user = @users.fetch(username.to_sym) {
              raise "User `#{username}` not found. " \
                    "Add it with `Verse::Http::Spec::HttpHelper.add_user(\"#{username}\", role, metadata, scopes)`" \
                    "in your spec_helper.rb"
            }

            Verse::Http::Auth::Token.encode(
              *user.values_at(:metadata, :role, :scopes),
              exp: Time.now.to_i + 1_000_000
            )
          end
        end

        def current_user
          Verse::Http::Spec::HttpHelper.current_user
        end

        def app
          Verse::Http::Server
        end

        %i[get put patch post delete].each do |method|
          define_method(method) do |path, params = {}, headers = {}|
            Verse::Auth::CheckAuthenticationHandler.disabled do
              if Verse::Http::Spec::HttpHelper.current_user
                headers["HTTP_AUTHORIZATION"] ||= "Bearer #{Verse::Http::Spec::HttpHelper.new_token(current_user)}"
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
