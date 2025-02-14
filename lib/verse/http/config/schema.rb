# frozen_string_literal: true

module Verse
  module Http
    module Config
      # The configuration schema for the Verse::Http::Server
      # plugin configuration
      Schema = Verse::Schema.define do
        field(:show_error_details, TrueClass).default(true)
        field(:validate_output, TrueClass).default(false)
      end
    end
  end
end
