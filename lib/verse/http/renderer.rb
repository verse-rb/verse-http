# frozen_string_literal: true

module Verse
  module Http
    module Renderer
      class << self
        attr_accessor :default_renderer
      end

      # Require the different standard renderers
      require_relative "renderer/identity"
      require_relative "renderer/json"
      require_relative "renderer/binary"
      require_relative "renderer/stream"

      @default_renderer = Http::Renderer::Json
    end
  end
end
