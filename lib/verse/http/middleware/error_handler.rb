# frozen_string_literal: true

require_relative "../with_renderer"

module Verse
  module Http
    module Middleware
      class ErrorHandler
        include Verse::Http::WithRenderer

        @handlers = {}

        class << self
          attr_reader :handlers

          def rescue_from(class_name = nil, &block)
            @handlers[class_name] = block
          end

          def clear_handler(class_name)
            @handlers.delete(class_name)
          end
        end

        def initialize(app)
          @app = app
        end

        # rubocop:disable Lint/RescueException
        def call(env)
          @output = nil
          @app.call(env)
        rescue Exception => e # Rescue all exceptions
          handle_error(e, env)
        end
        # rubocop:enable Lint/RescueException

        def handle_error(error, env)
          ancestors = error.class.ancestors

          handler = nil

          false until handler = self.class.handlers[ancestors.shift]

          instance_exec(error, env, &handler)

          output
        end
      end
    end
  end
end

require_relative "error_handlers/default"
