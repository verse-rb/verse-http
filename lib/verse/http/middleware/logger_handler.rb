# frozen_string_literal: true

module Verse
  module Http
    module Middleware
      class LoggerHandler

        def initialize(app)
          @app = app
        end

        def call(env)
          @rid = rand(0..0xFFFFFFFFFFFF).to_s(16).rjust(12, "0")
          @env = env
          time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          error = nil
          begin
            output = @app.call(env)
          rescue StandardError => error
            if error.class.respond_to?(:http_code)
              code = error.class.http_code
            else
              code = 500
            end

            time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - time
            Verse.logger.warn{ log_status(time, [code]) }
            Verse.logger.warn{ log_error(error) }
            raise error
          end

          time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - time

          if error_code?(output[0])
            Verse.logger.warn{ log_status(time, output) }
          else
            Verse.logger.info{ log_status(time, output) }
          end

          output
        end

        protected

        def log_status(time, output)
          "[#{@rid}] [#{output[0]}] #{@env["REQUEST_METHOD"]} #{@env["REQUEST_PATH"]} [#{human_readable_time(time)}]"
        end

        def log_error(e)
          "[#{@rid}] #{e.class.name} (#{e.message})"
        end

        def error_code?(status)
          (400..599).include?(status)
        end

        def human_readable_time(time)
          if time < 1
            "#{(time * 1000.0).round(2)}ms"
          else
            "#{time.round(2)}s"
          end
        end

      end
    end
  end
end
