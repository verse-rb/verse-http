# frozen_string_literal: true

module Verse
  module Http
    module Renderers
      class BinaryRenderer

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

          if detected_content_type
            detected_extension = MimeMagic.new(detected_content_type).extensions.first

            @content_type ||= detected_content_type
            @extension ||= detected_extension
          end
        end

        def render(result, ctx)
          data = result.body

          guess_type(data)

          ctx.content_type @content_type || DEFAULT_CONTENT_TYPE
          ctx.attachment create_attachment_name

          data
        end
      end
    end
  end
end