# frozen_string_literal: true

RSpec.describe Verse::Http::Renderer::Json do
  let(:renderer) { Verse::Http::Renderer::Json.new }

  let(:ctx) {
    server = double("server")
    allow(server).to receive(:content_type)
    ctx = double("ctx")
    allow(ctx).to receive(:[]).with("verse.http.server").and_return(server)

    ctx
  }

  describe "#render" do
    it "returns the result" do
      result = { hello: "world" }

      renderer.pretty = false
      expect(renderer.render(result, ctx)).to eq "{\"hello\":\"world\"}"
    end

    it "returns the result (pretty)" do
      result = { hello: "world" }

      renderer.pretty = true
      expect(renderer.render(result, ctx)).to eq "{\n  \"hello\": \"world\"\n}"
    end
  end
end
