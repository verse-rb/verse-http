# frozen_string_literal: true

module Verse
  module Http
    module Config
      # The configuration schema for the Verse::Http::Server
      # plugin configuration
      class Schema < Verse::Validation::Contract
        SERVICE_NAME = /[a-z0-9_-]+/.freeze
        PLUGIN_NAME = /[a-z0-9_]+( <[a-zA-Z0-9:]+>)?/.freeze

        params do
          optional(:show_error_details).filled(:bool)
        end
      end
    end
  end
end
