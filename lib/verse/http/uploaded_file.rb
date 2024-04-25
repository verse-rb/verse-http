module Verse
  module Http
    UploadedFileStruct = Struct.new(:filename, :type, :name, :tempfile, :head, keyword_init: true)

    UploadedFile = Verse::Schema.define do
      field?(:filename, String)
      field(:type, String).default("application/octet-stream")
      field?(:name, String)
      field(:tempfile, Tempfile)
      field?(:head, String)

      transform do |data|
        UploadedFileStruct.new(**data)
      end
    end
  end
end
