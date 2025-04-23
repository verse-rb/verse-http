# frozen_string_literal: true

module Verse
  module Http
    class Plugin < Verse::Plugin::Base
      class << self
        attr_accessor :show_error_details, :validate_output

        def show_error_details?
          @show_error_details
        end

        def validate_output?
          @validate_output
        end
      end

      def description
        "Serve HTTP endpoints using Sinatra as HTTP server."
      end

      def validate_config
        result = Config::Schema.validate(config)

        unless result.success?
          raise "Invalid config for http plugin: #{result.errors}"
        end

        self.class.show_error_details = result.value.fetch(:show_error_details)
        self.class.validate_output = result.value.fetch(:validate_output)
      end

      def on_init
        validate_config

        require_relative "../http"
      end

      def on_start(_mode)
        Verse::Http::RoutesCollection.register!
      end
    end
  end
end
