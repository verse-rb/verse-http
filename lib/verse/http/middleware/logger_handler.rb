module Verse
  module Http
    module Middleware
      class LoggerHandler

        def initialize(app) # rubocop:disable Lint/MissingSuper
          @app = app
        end

        def is_error_code?(status)
          (400..599).include?(status)
        end

        def call(env)
          error = nil

          begin
            time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            output = @app.call(env)

            time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - time

            log_content = -> { "#{output[0]} #{env["REQUEST_METHOD"]} #{env["REQUEST_PATH"]} [#{(time * 1000).to_i}ms]" }

            if is_error_code? output[0]
              Verse.logger.warn(&log_content)
            else
              Verse.logger.info(&log_content)
            end

            return output
          rescue RuntimeError => e
            time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - time
            Verse.logger.warn(e)

            raise
          end
        end

      end
    end
  end
end
