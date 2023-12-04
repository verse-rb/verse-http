# frozen_string_literal: true

module Verse
  module Http
    module Renderer
      class Identity
        def render(result, _ctx)
          result
        end
      end
    end
  end
end
