# frozen_string_literal: true

RSpec.describe Verse::Http::Renderer::Json do
  let(:renderer) { Verse::Http::Renderer::Json.new }

  describe "#render" do
    it "returns the result" do
      result = { hello: "world" }

      ctx = double("ctx")
      expect(ctx).to receive(:content_type).twice

      renderer.pretty = false
      expect(renderer.render(result, ctx)).to eq "{\"hello\":\"world\"}"
    end

    it "returns the result (pretty)" do
      result = { hello: "world" }

      ctx = double("ctx")
      expect(ctx).to receive(:content_type).twice

      renderer.pretty = true
      expect(renderer.render(result, ctx)).to eq "{\n  \"hello\": \"world\"\n}"
    end
  end
end
