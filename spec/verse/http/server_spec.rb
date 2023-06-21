# frozen_string_literal: true

require "spec_helper"

RSpec.describe Verse::Http::Server do
  let(:app) { Verse::Http::Server }

  before do
    Verse.start(
      :test,
      config_path: "./spec/verse/spec_data/config.yml"
    )

    load File.expand_path("../spec_data/sample_expo.rb", __dir__)
    SampleExpo.register
  end

  after do
    Verse.stop
  end

  describe "GET /" do
    it "returns 200 OK" do
      get "/"

      expect(last_response.status).to eq 200
    end
  end

  describe "GET /hello" do
    it "returns 404 NOT FOUND" do
      get "/hello"

      expect(last_response.status).to eq 404
    end
  end
end
