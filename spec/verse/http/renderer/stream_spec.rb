# frozen_string_literal: true

RSpec.describe Verse::Http::Renderer::Stream do
  let(:renderer) { Verse::Http::Renderer::Stream.new }

  describe "#render" do
    it "returns the result" do
      result = StringIO.new("hello world")

      ctx = double("ctx")

      expect(ctx).to receive(:content_type)

      # Fake the streaming system
      output = String.new
      expect(ctx).to receive(:stream) do |&block|
        block.call(output)
      end
      renderer.render(result, ctx)

      expect(output).to eq "hello world"
    end
  end
end
