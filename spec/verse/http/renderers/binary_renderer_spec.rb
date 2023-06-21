RSpec.describe Verse::Http::Renderers::BinaryRenderer do
  let(:renderer) { Verse::Http::Renderers::BinaryRenderer.new }

  describe "#render" do
    it "returns the result" do
      io = StringIO.new("hello world")

      ctx = double("ctx")
      expect(ctx).to receive(:content_type).with("application/octet-stream")
      expect(ctx).to receive(:attachment).with(String)

      expect(renderer.render(io, ctx)).to eq io
    end

    it "allows to set custom content type" do
      io = StringIO.new("hello world")

      ctx = double("ctx")
      expect(ctx).to receive(:content_type).with("image/png")
      expect(ctx).to receive(:attachment).with(String)

      renderer.content_type = "image/png"

      expect(renderer.render(io, ctx)).to eq io
    end

    it "allows to set custom attachment name" do
      result = double("result")
      io = StringIO.new("hello world")

      ctx = double("ctx")
      expect(ctx).to receive(:content_type).with("application/octet-stream")
      expect(ctx).to receive(:attachment).with("hello.png")

      renderer.attachment_name = "hello.png"

      expect(renderer.render(io, ctx)).to eq io
    end

    it "automatically detect content type" do
      MimeMagic.add('application/mimemagic-test',
        magic: [[0, 'MAGICTEST']]
      )

      io = StringIO.new("MAGICTEST")

      ctx = double("ctx")
      expect(ctx).to receive(:content_type).with("application/mimemagic-test")
      expect(ctx).to receive(:attachment).with(String)

      renderer.render(io, ctx)
    end
  end
end