# frozen_string_literal: true

require "spec_helper"

RSpec.describe Verse::Http::Rest do

  before do
    Verse.start(
      :test,
      config_path: "./spec/verse/spec_data/config.yml"
    )

    require_relative "./rest_data/sample"

    Spec::Rest::FooExpo.register
  end

  it "generates the correct routes" do
  end

end