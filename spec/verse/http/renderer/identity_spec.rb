# frozen_string_literal: true

RSpec.describe Verse::Http::Renderer::Identity do
  let(:renderer) { Verse::Http::Renderer::Identity.new }

  describe "#render" do
    it "returns the result" do
      expect(renderer.render("hello world", nil)).to eq "hello world"
    end
  end
end
