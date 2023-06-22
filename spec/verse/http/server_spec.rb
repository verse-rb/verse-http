# frozen_string_literal: true

require "spec_helper"

RSpec.describe Verse::Http::Server do
  let(:app) { Verse::Http::Server }

  before do
    Verse.start(
      :test,
      config_path: "./spec/verse/spec_data/config.yml"
    )

    load File.expand_path("../spec_data/test_expo.rb", __dir__)
    TestExpo.register
  end

  after do
    Verse.stop
  end

  describe "200 check" do
    it "returns 200 OK" do
      get "/"

      expect(last_response.status).to eq 200
    end
  end

  describe "404 check" do
    it "returns 404 NOT FOUND" do
      get "/hello"

      expect(last_response.status).to eq 404
    end
  end

  describe "exposed endpoints" do
    it "test the identity renderer" do
      get "/test/identity"


      expect(last_response.status).to eq 200
      expect(last_response.body).to eq "hello world"
    end

    it "test the no auth renderer" do
      get "/test/no_auth"

      binding.pry

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq "hello world"
    end
  end
end
