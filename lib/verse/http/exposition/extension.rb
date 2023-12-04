# frozen_string_literal: true

require_relative "./hook"

module Verse
  module Http
    module Exposition
      ##
      # The extension module for Verse::Http::Exposition::Base
      # @see Verse::Http::Exposition::Base
      module Extension
        ##
        # Set the base HTTP path for this exposition
        #
        # @param [String] value The base path which will be prepended to any
        # exposition path.
        #
        # @return [String] The base path
        def http_path(value = nil)
          if value
            @base_http_path = value
          else
            @base_http_path
          end
        end

        # Set the default renderer for this exposition
        # @param [Symbol] renderer The renderer to use
        # @return [Symbol] The default renderer
        def renderer(renderer = nil)
          if renderer
            @renderer = renderer
          else
            @renderer || Verse::Http::Renderer.default_renderer
          end
        end

        # Create a new hook for this exposition
        # @param [Symbol] method The HTTP method to use. Can be +:get+, +:post+,
        #   +:patch+, +:delete+ or +:put+
        # @param [String] path The path to use for this hook. Your server will
        #   listen to this path.
        # @param [Hash] opts Options for this hook.
        # @option opts [Symbol] :auth The auth strategy to use for this hook.
        # @option opts [Symbol] :renderer The renderer to use for this hook.
        # @return [Hook] The created hook
        #
        # @see Hook
        #
        # @example
        #  class MyExposition < Verse::Exposition::Base
        #    http_path "/my_exposition"
        #    renderer :identity # return the content as-is.
        #
        #   expose on_http(:get, "/hello_world", auth: nil)
        #   def hello_world
        #     "hello world"
        #   end
        #  end
        def on_http(method, path = "", **opts)
          Hook.new(self, method, path, renderer: @renderer, **opts)
        end
      end
    end
  end
end
