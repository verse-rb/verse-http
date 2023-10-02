# frozen_string_literal: true

require_relative "../error_handler"

Verse::Http::Middleware::ErrorHandler.rescue_from Verse::Error::Base do |e|
  meta      = e.meta
  source    = e.source
  details   = e.details || {}
  error_key = e.class.message

  details_hash = local_message_list(error_key, details)
  details_hash.merge!(backtrace: e.backtrace) if Verse::Http::Plugin.show_error_details?
  details_hash.merge!(details)

  render JSON.pretty_generate(errors: [{
    status: e.class.http_code.to_s,
    type: "ms_error",
    code: e.class.code.to_s,
    title: error_key,
    detail: details_hash,
    source:,
    meta:
  }.compact]), status: e.class.http_code
end
