require_relative "../error_handler"

# Default handler, used when no handler is available
Verse::Http::Middleware::ErrorHandler.rescue_from do |e|
  error_code = Digest::SHA2.hexdigest([e.message, e.backtrace.join("\n")].join("\n"))[0..7]

  struct = {
      type:   "error",
      status: "500",
      title:  "verse.errors.server_error",
      code: error_code,
      details: ({
        message: e.message,
        backtrace: e.backtrace
      } if Verse::Http::Plugin.show_error_details?)
    }.compact

  render JSON.pretty_generate(struct), status: 500
end

