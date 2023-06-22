module Verse
  module Http
    module Renderer
      @renderers = {}
      @default_renderer = :json

      class << self
        attr_reader :renderers
        attr_accessor :default_renderer

        def [](name)
          renderers.fetch(name) do
            renderers.fetch(default_renderer)
          end
        end

        def[]=(name, value)
          renderers[name] = value
        end
      end
    end

    # Require the different standard renderers
    require_relative "renderer/identity"
    require_relative "renderer/json"
    require_relative "renderer/binary"
    require_relative "renderer/stream"
  end
end

