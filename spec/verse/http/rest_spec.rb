# frozen_string_literal: true

require "spec_helper"

RSpec.describe Verse::Http::Rest, type: :exposition do

  before do
    Verse.start(
      :test,
      config_path: "./spec/verse/spec_data/config.yml"
    )

    require_relative "./rest_data/sample"

    Spec::Rest::FooExpo.register
  end

  context "routes generation" do
    it "#index", as: :user do
      get "/foo"
      binding.pry
      expect(last_response.status).to eq(200)
    end

  end


end