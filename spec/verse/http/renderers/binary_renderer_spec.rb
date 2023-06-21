RSpec.describe Verse::Http::Renderers::BinaryRenderer do
  let(:renderer) { Verse::Http::Renderers::BinaryRenderer.new }

  describe "#render" do
    it "returns the result" do
      result = double("result")
      io = StringIO.new("hello world")
      expect(result).to receive(:body).and_return(io)

      ctx = double("ctx")
      expect(ctx).to receive(:content_type).with("application/octet-stream")
      expect(ctx).to receive(:attachment).with(String)

      expect(renderer.render(result, ctx)).to eq io
    end
  end
end