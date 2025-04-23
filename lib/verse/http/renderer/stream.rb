# frozen_string_literal: true

module Verse
  module Http
    module Renderer
      class Stream
        DEFAULT_CONTENT_TYPE = "application/octet-stream"

        @buffer_size = 8192

        class << self
          attr_accessor :buffer_size
        end

        def initialize
          @content_type = DEFAULT_CONTENT_TYPE
        end

        attr_accessor :content_type

        def render(result, server)
          server.content_type content_type

          return unless result

          result.rewind

          buffer_size = self.class.buffer_size

          server.stream do |out|
            until result.eof?
              data = result.read buffer_size
              out << data
            end

            out
          end
        end
      end
    end
  end
end
