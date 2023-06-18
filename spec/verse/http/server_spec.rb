RSpec.describe Verse::Http::Server do
  let(:app) { Verse::Http::Server }

  before do
    Verse.start(
      :test,
      config_path: "./spec/verse/spec_data/config.yml"
    )
  end

  describe "GET /" do
    it "returns 200 OK" do
      get "/"

      expect(last_response.status).to eq 200
    end
  end

end