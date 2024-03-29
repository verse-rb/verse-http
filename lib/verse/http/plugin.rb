# frozen_string_literal: true

module Verse
  module Http
    class Plugin < Verse::Plugin::Base
      class << self
        attr_accessor :show_error_details

        def show_error_details?
          @show_error_details
        end
      end

      def description
        "Serve HTTP endpoints using Sinatra as HTTP server."
      end

      def validate_config
        result = Config::Schema.validate(config)
        self.class.show_error_details = result.value.fetch(:show_error_details)

        return if result.success?

        raise "Invalid config for http plugin: #{result.errors}"
      end

      def on_init
        validate_config

        require_relative "../http"

        Verse::Exposition::ClassMethods.prepend(
          Verse::Http::Exposition::Extension
        )
      end

      def on_start(_mode)
        Verse::Http::RoutesCollection.register!
      end
    end
  end
end
