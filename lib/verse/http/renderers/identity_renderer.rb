# frozen_string_literal: true

module Verse
  module Http
    module Renderers
      class IdentityRenderer
        def render(result, _ctx)
          result
        end
      end
    end
  end
end
