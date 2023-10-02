# frozen_string_literal: true

require_relative "./spec/http_helper"

RSpec.configure do |c|
  c.include Verse::Http::Spec::HttpHelper, type: :exposition
end
