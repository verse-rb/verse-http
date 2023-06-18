# frozen_string_literal: true
require "json"

module Verse
  module Http
    module Renderers
      class JsonRenderer
        attr_accessor :pretty

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
