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
          begin
            output = @app.call(env)
          rescue StandardError => e
            code = if e.class.respond_to?(:http_code)
                     e.class.http_code
                   else
                     500
                   end

            time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - time
            Verse.logger.warn{ log_status(time, [code]) }
            Verse.logger.warn{ log_error(e) }
            raise e
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

        def log_error(error)
          out = "[#{@rid}] #{error.class.name} (#{error.message})"

          if Verse::Http::Plugin.show_error_details? && error.backtrace
            out << "\n"
            out << error.backtrace.map{ |x| "[#{@rid}] #{x}" }.join("\n")
          end

          out
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
