# frozen_string_literal: true

require_relative "../error_handler"

# Default handler, used when no handler is available
Verse::Http::Middleware::ErrorHandler.rescue_from do |e|
  error_code = Digest::SHA2.hexdigest([e.message, e.backtrace.join("\n")].join("\n"))[0..7]

  struct = {
    type: "error",
    status: "500",
    title: "verse.errors.server_error",
    code: error_code,
    details: (if Verse::Http::Plugin.show_error_details?
                {
                  class: e.class.to_s,
                  message: e.message,
                  backtrace: e.backtrace
                }
              end)
  }.compact

  render JSON.pretty_generate(struct), status: 500
end
