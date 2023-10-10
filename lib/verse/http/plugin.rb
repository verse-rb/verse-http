# frozen_string_literal: true

module Verse
  module Http
    class Plugin < Verse::Plugin::Base
      class << self
        attr_accessor :show_error_details

        def show_error_details?
          true
          # !!@show_error_details
        end
      end

      def description
        "Serve HTTP endpoints using Sinatra as HTTP server."
      end

      def validate_config
        result = Config::Schema.new.call(config)

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

      def on_start(mode)
        return unless mode == :server
      end
    end
  end
end
