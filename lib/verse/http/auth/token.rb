# frozen_string_literal: true

require "jwt"

module Verse
  module Http
    module Auth
      # This is a simple role based token authentication strategy.
      class Token
        # It uses ECDSA as the signing algorithm, because it is attended
        # to be used with microservices, and we want only the authentication
        # service to be able to forge a new token.
        @sign_algorithm = "ES256"

        class << self
          attr_accessor :sign_algorithm, :sign_key, :role_backend

          def decode(token, validate: true, **opts)
            payload, = JWT.decode(
              token, sign_key, validate, { algorithm: sign_algorithm, **opts }
            )

            new(payload)
          end

          def encode(user, role, scopes, **opts)
            JWT.encode({
                         u: user,
                         r: role,
                         s: scopes
                       }, sign_key, sign_algorithm, opts)
          end
        end

        attr_reader :user, :role, :scopes

        include Verse::Util::HashUtil

        def initialize(payload)
          payload.values_at("u", "r", "s").tap do |user, role, scopes|
            rights = self.class.role_backend.fetch(role)

            Verse::Auth::Context.new(
              rights,
              custom_scopes: scopes,
              metadata: user
            )

            @user = deep_symbolize_keys(user)
            @role = role.to_sym
            @scopes = deep_symbolize_keys(scopes)
          end
        end
      end
    end
  end
end
