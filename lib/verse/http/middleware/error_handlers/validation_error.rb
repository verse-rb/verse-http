require_relative "../error_handler"

Verse::Http::Middleware::ErrorHandler.rescue_from Verse::Error::ValidationFailed do |e|
  meta      = e.meta
  source    = e.source

  render JSON.pretty_generate(
    errors: source.map do |error|
      key = error[:key].gsub(' ', '_')
      details = error[:details] || {}
      details_hash = local_message_list(key, details)
      details_hash.merge!( backtrace: e.backtrace ) if Verse::Http::Plugin.show_error_details?
      details_hash.merge!(details)


      {
        status: e.class.http_code.to_s,
        type: "validation_error",
        code: "E422",
        title: key,
        detail: details_hash,
        source: {
          model: error[:model],
          parameter: error[:parameter]
        },
        meta: meta
      }.compact
    end
  ), status: e.class.http_code
end