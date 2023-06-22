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
        @role_backend = Verse::Http::Auth::SimpleRoleBackend

        class << self
          # The algorithm used to sign the token.
          # By default, use ECDSA 256 bits.
          attr_accessor :sign_algorithm

          # The key used to sign the token. It could
          # contains the private and public key pair,
          # allowing this service to forge new tokens,
          # or just the public key, allowing this service
          # to only validate tokens.
          attr_accessor :sign_key

          # Backend used to fetch roles. By default, relay on the roles
          # setup into the Verse::Auth::Context class.
          attr_accessor :role_backend

          # Decode a token.
          # @param token [String] The token to decode.
          # @param validate [Boolean] Validate the token (check expiration, and other headers fields).
          # @param opts [Hash] Options to pass to the JWT library.
          #
          # @return [Verse::Http::Auth::Token] The decoded token.
          def decode(token, validate: true, **opts)
            payload, = JWT.decode(
              token, sign_key, validate, { algorithm: sign_algorithm, **opts }
            )

            new(payload)
          rescue JWT::DecodeError => e
            raise Verse::Error::Authorization, e.message
          end

          # Encode a token.
          # @param user [Hash] The user metadata.
          # @param role [Symbol] The user role.
          # @param scopes [Hash] The user scopes.
          # @param opts [Hash] Extra keys to the payload
          def encode(user, role, scopes, **opts)
            JWT.encode({
                         u: user,
                         r: role,
                         s: scopes,
                         **opts
                       }, sign_key, sign_algorithm)
          end
        end

        include Verse::Util::HashUtil

        # The authentication context linked to this token.
        attr_reader :context

        # Initialize the token and build the authentication context from it.
        def initialize(payload)
          payload.values_at("u", "r", "s").tap do |user, role, scopes|
            rights = self.class.role_backend.fetch(role)

            @context = Verse::Auth::Context.new(
              rights,
              custom_scopes: deep_symbolize_keys(scopes),
              metadata: { **deep_symbolize_keys(user), role: role.to_sym }
            )
          end
        end
      end
    end
  end
end
