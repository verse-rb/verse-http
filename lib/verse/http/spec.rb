# frozen_string_literal: true

require "rack/test"
require_relative "./spec/http_helper"

RSpec.configure do |c|
  c.include Rack::Test::Methods, type: :exposition
  c.include Verse::Http::Spec::HttpHelper, type: :exposition

  c.around(:each, :as, type: :exposition) do |example|
    Verse::Http::Spec::HttpHelper.current_user = example.metadata[:as]
    example.run
  ensure
    Verse::Http::Spec::HttpHelper.current_user = nil
  end
end
