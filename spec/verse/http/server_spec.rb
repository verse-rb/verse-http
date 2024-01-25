# frozen_string_literal: true

require "spec_helper"

RSpec.describe Verse::Http::Server, type: :exposition do
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
      get "/_service"

      expect(last_response.status).to eq 200
    end
  end

  describe "404 check" do
    it "returns 404 NOT FOUND" do
      silent do
        get "/hello"

        expect(last_response.status).to eq 404
      end
    end
  end

  describe "exposed endpoints" do
    let(:authorization_token) {
      Verse::Http::Auth::Token.encode(
        { id: 1, name: "toto" }, "user", { users: 1 }
      )
    }

    let(:expired_authorization_token) {
      Verse::Http::Auth::Token.encode(
        { id: 1, name: "toto" }, "user", { users: 1 }, exp: Time.now.to_i - 1000
      )
    }

    context "authorization check (identity renderer)" do
      it "returns 401 UNAUTHORIZED" do
        silent do
          get "/test/identity"

          expect(last_response.status).to eq 401
        end
      end

      it "returns 401 if token is expired" do
        silent do
          get "/test/identity", {}, {
            "HTTP_AUTHORIZATION" => "Bearer #{expired_authorization_token}"
          }

          expect(last_response.status).to eq 401
        end
      end

      it "returns 200 OK" do
        get "/test/identity", {}, {
          "HTTP_AUTHORIZATION" => "Bearer #{authorization_token}"
        }

        expect(last_response.status).to eq 200
        expect(last_response.body).to eq "hello world"
      end

      it "returns 200 OK with cookie" do
        clear_cookies
        set_cookie "authorization=#{authorization_token}"

        get "/test/identity", {}

        expect(last_response.status).to eq 200
      end
    end

    it "test the no auth renderer" do
      get "/test/no_auth"

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq "\"hello world\""
    end
  end
end
