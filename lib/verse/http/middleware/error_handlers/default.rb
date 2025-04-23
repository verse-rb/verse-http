# frozen_string_literal: true

require_relative "../error_handler"

# Default handler, used when no handler is available
Verse::Http::Middleware::ErrorHandler.rescue_from nil do |e, env|
  renderer  = env["verse.http.renderer"]
  server    = env["verse.http.server"]

  code = if e.class.respond_to?(:http_code)
           e.class.http_code
         else
           500
         end

  if renderer.respond_to?(:render_error)
    output = renderer.render_error(e, server)

    if server.response.status < 400 # If not set in the render_error block
      server.response.status = code
    end

    render output, status: server.response.status
  else
    # Standard json error format
    error = {
      status: code.to_s,
      type: e.class.name,
      detail: e.message,
      backtrace: ( e.backtrace if Verse::Http::Plugin.show_error_details? )
    }.compact

    render JSON.pretty_generate(error), status: code
  end
end
