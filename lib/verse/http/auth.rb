module Verse
  module Http
    module Auth
      module_function

      @strategies = {
        default: proc do |env, &block|
          request = Rack::Request.new(env)

          authorization = request.env.fetch("HTTP_AUTHORIZATION") {
            request.cookies["authorization"]
          }

          if authorization
            raise "TODO"
          else
            auth_context = Verse::Auth::Context[:anonymous]
          end

          env["auth_context"] = auth_context

          block.call(auth_context)
        end,

        none: proc do |env, &block|
          block.call(Verse::Auth::Context[:anonymous])
        end
      }

      @roles = {}

      def add_role(name, &block)
        @roles[name] = RoleDSL.new(&block).role
      end

      def add_strategy(name, &block)
        @strategies[name] = block
      end

      def get(name)
        @strategies.fetch(name || :none)
      end

    end
  end
end
