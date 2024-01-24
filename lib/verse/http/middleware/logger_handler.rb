# frozen_string_literal: true

module Verse
  module Http
    module Middleware
      class LoggerHandler
        def initialize(app)
          @app = app
        end

        def error_code?(status)
          (400..599).include?(status)
        end

        def call(env)
          time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          output = @app.call(env)

          time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - time

          log_content = -> { "#{output[0]} #{env["REQUEST_METHOD"]} #{env["REQUEST_PATH"]} [#{(time * 1000).to_i}ms]" }

          if error_code? output[0]
            Verse.logger.warn(&log_content)
          else
            Verse.logger.info(&log_content)
          end

          output
        rescue => e
          time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - time
          Verse.logger.warn(e)

          raise
        end
      end
    end
  end
end
