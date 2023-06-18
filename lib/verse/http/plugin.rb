
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

      end

      def on_init
        validate_config

        require_relative "exposition/extension"
        require_relative "http/server"

        Verse::Exposition::ClassMethods.prepend(
          Verse::Http::Exposition::Extension
        )
      end

      def on_start(mode)
        if mode == :server
          Verse::Http::Server.start!
        end
      end
    end
  end
end
