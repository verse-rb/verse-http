# frozen_string_literal: true


module Verse
  module Http
    module Renderers
      class StreamRenderer
        BUFFER_SIZE = 8192
        DEFAULT_CONTENT_TYPE = "application/octet-stream"

        attr_accessor :content_type

        def render(result, ctx)
          ctx.content_type self.content_type || DEFAULT_CONTENT_TYPE

          return unless result

          ctx.stream do |out|
            until result.eof?
              data = result.read(BUFFER_SIZE)
              out << data
            end

            out
          end
        end

      end
    end
  end
end
