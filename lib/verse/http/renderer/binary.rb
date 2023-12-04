# frozen_string_literal: true

module Verse
  module Http
    module Renderer
      # A renderer used to output binary data
      # expect the result to be a IO object.
      # It will set the content type using mime magic
      # if it is available.
      # If not, it will default to application/octet-stream.
      class Binary
        DEFAULT_CONTENT_TYPE = "application/octet-stream"

        attr_accessor :attachment_name,
                      :content_type,
                      :extension

        def create_attachment_name
          return @attachment_name if @attachment_name

          [
            "file_#{Time.now.to_i}",
            @extension
          ].compact.join(".")
        end

        def guess_type(data)
          return unless defined?(MimeMagic)

          detected_content_type = MimeMagic.by_magic(data)&.type

          return unless detected_content_type

          detected_extension = MimeMagic.new(detected_content_type).extensions.first

          @content_type ||= detected_content_type
          @guess_type ||= detected_extension
        end

        def render(result, ctx)
          return unless result

          result.rewind

          guess_type(result)

          ctx.content_type @content_type || DEFAULT_CONTENT_TYPE
          ctx.attachment create_attachment_name

          result
        end
      end
    end
  end
end
