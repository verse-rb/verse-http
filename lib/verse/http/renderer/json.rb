# frozen_string_literal: true

require "json"

module Verse
  module Http
    module Renderer
      class Json
        include Verse::Http::WithRenderer

        @pretty = true

        class << self
          attr_accessor :pretty
        end

        attr_accessor :pretty

        def initialize(pretty = self.class.pretty, show_error_details = Verse::Http::Plugin.show_error_details?)
          @pretty = pretty
          @show_error_details = show_error_details
        end

        def render_error(error, ctx)
          server = ctx["verse.http.server"]
          server.content_type(server.content_type || "application/json")

          code = if error.class.respond_to?(:http_code)
                   error.class.http_code
                 else
                   500
                 end

          result = {
            status: code.to_s,
            type: error.class.name,
            detail: error.message
          }.compact

          result[:backtrace] = error.backtrace if @show_error_details

          if pretty
            JSON.pretty_generate(result)
          else
            JSON.generate(result)
          end
        end

        def render(result, ctx)
          server = ctx["verse.http.server"]
          server.content_type(server.content_type || "application/json")

          if pretty
            JSON.pretty_generate(result)
          else
            JSON.generate(result)
          end
        end
      end
    end
  end
end
