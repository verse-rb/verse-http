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
        @sign_algorithm = 'ES256'

        class << self
          attr_accessor :sign_algorithm
          attr_accessor :sign_key

          def decode(token)
            payload = JWT.decode(token, sign_key, true, { algorithm: sign_algorithm })
            new(payload)
          end
        end

        def initialize(payload)
          payload.values_at("u", "r").tap do |user_id, role|
            Verse::Auth::Context.new(user_id, role)

            @user = user
            @role = role
          end
        end

      end
    end
  end
end
