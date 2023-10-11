# frozen_string_literal: true

require_relative "./with_renderer"

module Verse
  module Http
    module Middleware
      class ErrorHandler
        include WithRenderer

        @handlers = {}

        class << self
          attr_reader :handlers

          def rescue_from(class_name = nil, &block)
            @handlers[class_name] = block
          end

          def clear_handler(class_name)
            @handlers.delete(class_name)
          end

          def flavor_rescue_from(class_name, &block)
            handler = @handlers[class_name]

            flavored_handler = ->(err) do
              instance_exec(err){ block.call(&handler) }
            end

            @handlers[class_name] = flavored_handler
          end
        end

        def initialize(app)
          @app = app
        end

        def local_message_list(error_key, details = {})
          details ||= {}

          ::I18n.available_locales.map do |loc|
            [loc, ::I18n.with_locale(loc){ ::I18n.t(error_key, **details) }]
          end.to_h
        end

        def call_impl(env)
          @app.call(env)
        rescue Exception => e # Rescue all exceptions
          handle_error(e)
        end

        def handle_error(error)
          ancestors = error.class.ancestors

          handler = nil

          false until handler = self.class.handlers[ancestors.shift]

          instance_exec(error, &handler)

          output
        end
      end
    end
  end
end

require_relative "error_handlers/default"
require_relative "error_handlers/verse_error"
require_relative "error_handlers/validation_error"
