# frozen_string_literal: true

RSpec.describe Verse::Http::Renderer::Json do
  let(:renderer) { Verse::Http::Renderer::Json.new }

  let(:server) {
    server = double("server")
    allow(server).to receive(:content_type)
    server
  }

  describe "#render" do
    it "returns the result" do
      result = { hello: "world" }

      renderer.pretty = false
      expect(renderer.render(result, server)).to eq "{\"hello\":\"world\"}"
    end

    it "returns the result (pretty)" do
      result = { hello: "world" }

      renderer.pretty = true
      expect(renderer.render(result, server)).to eq "{\n  \"hello\": \"world\"\n}"
    end
  end
end
