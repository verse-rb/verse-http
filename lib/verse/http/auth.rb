# frozen_string_literal: true

module Verse
  module Http
    module Auth
      extend self

      @auth_cookie = "authorization"
      @auth_header = "HTTP_AUTHORIZATION"

      attr_accessor :auth_cookie, :auth_header

      @strategies = {
        default: proc do |env, &block|
          request = Rack::Request.new(env)

          auth = request.env[@auth_header]

          if auth && auth =~ /^Bearer /
            credentials = auth.split(" ")[1]
          elsif @auth_cookie
            credentials = request.cookies[@auth_cookie]
          end

          raise Error::Authorization, "unauthorized_access" unless credentials

          token = Verse::Http::Auth::Token.decode(credentials)
          auth_context = token.context

          env["auth_context"] = auth_context
          block.call(auth_context)
        end,

        nil => proc do |env, &block|
          auth_context = Verse::Auth::Context[:anonymous]

          # Ignore check on nil authorization
          auth_context.mark_as_checked!

          env["auth_context"] = auth_context
          block.call(auth_context)
        end
      }

      def add_strategy(name, &block)
        @strategies[name] = block
      end

      def get(name)
        @strategies.fetch(name)
      end
    end
  end
end
