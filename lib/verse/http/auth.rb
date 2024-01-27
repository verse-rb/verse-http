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

          block.call(auth_context)
        end,

        nil => proc do |_env, &block|
          rights = Verse::Http::Auth::Token.role_backend.fetch("anonymous")

          auth_context = Verse::Auth::Context.new(
            rights,
            metadata: { role: "anonymous" }
          )

          # Ignore check on nil authorization
          auth_context.mark_as_checked!

          block.call(auth_context)
        end
      }

      # Add a new strategy
      # @param name [Symbol] the name of the strategy
      # @param block [Proc] the block used to define the strategy
      def add_strategy(name, &block)
        @strategies[name] = block
      end

      # Get a authentication strategy
      # @param name [Symbol] the name of the strategy
      # @return [Proc] the strategy
      def get(name)
        @strategies.fetch(name) {
          raise "unable to find auth strategy `#{name.inspect}`"
        }
      end
    end
  end
end
