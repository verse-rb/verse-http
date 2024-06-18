# frozen_string_literal: true

require "rack/test"
require_relative "./spec/http_helper"

RSpec.configure do |c|
  c.include Rack::Test::Methods, type: :exposition
  c.include Verse::Http::Spec::HttpHelper, type: :exposition

  c.before(:suite) do
    # Generate Private/public key pair:
    ecdsa_key = OpenSSL::PKey::EC.generate("prime256v1")

    # Use the key pair to sign and verify JWT tokens:
    Verse::Http::Auth::Token.sign_key = ecdsa_key
  end
end
