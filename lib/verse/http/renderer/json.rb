# frozen_string_literal: true

require "json"

module Verse
  module Http
    module Renderer
      class Json
        @pretty = true

        class << self
          attr_accessor :pretty
        end

        attr_accessor :pretty

        def initialize(_pretty = self.class.pretty)
          @pretty = self.class.pretty
        end

        def render(result, ctx)
          ctx.content_type(ctx.content_type || "application/json")

          if pretty
            JSON.pretty_generate(result)
          else
            result.to_json
          end
        end
      end
    end
  end
end
