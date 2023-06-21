RSpec.describe Verse::Http::Renderers::IdentityRenderer do
  let(:renderer) { Verse::Http::Renderers::IdentityRenderer.new }

  describe "#render" do
    it "returns the result" do
      expect(renderer.render("hello world", nil)).to eq "hello world"
    end
  end
end