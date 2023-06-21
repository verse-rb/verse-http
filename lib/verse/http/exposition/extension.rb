# frozen_string_literal: true

require_relative "./hook"

module Verse
  module Http
    module Exposition
      module Extension
        def http_path(value = nil)
          if value
            @base_http_path = value
          else
            @base_http_path
          end
        end

        def renderer(renderer = nil)
          if renderer
            @renderer = renderer
          else
            @renderer
          end
        end

        def on_http(method, path = "", **opts)
          Hook.new(self, method, path, **opts)
        end
      end
    end
  end
end
