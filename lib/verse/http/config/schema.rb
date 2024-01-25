# frozen_string_literal: true

module Verse
  module Http
    module Config
      # The configuration schema for the Verse::Http::Server
      # plugin configuration
      Schema = Verse::Schema.define do
        field(:show_error_details, TrueClass).optional
      end
    end
  end
end
