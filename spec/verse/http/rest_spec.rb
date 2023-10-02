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

    # Register a few foo records:
    Spec::Rest::FooRepository.clear

    repo = Spec::Rest::FooRepository.new(Verse::Auth::Context[:system])

    repo.create(bar: "1", data: [1, 2, 3, 4], test: "foo")
    repo.create(bar: "2", data: [1, 2, 3, 4], test: "bar")
    repo.create(bar: "3", data: [1, 2, 3, 4], test: "bar")
    repo.create(bar: "4", data: [1, 2, 3, 4], test: "foo")
    repo.create(bar: "5", data: [1, 2, 3, 8], test: "foo")
  end

  after do
    Verse.stop
  end

  context "routes generation", as: :user do
    context "#index" do
      it "basic call" do
        get "/foo"
        expect(last_response.status).to eq(200)
      end

      it "with pagination" do
        get "/foo?page=1&per_page=2"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq({
                                                                              data: [
                                                                                { id: 1, bar: "1", data: [1, 2, 3, 4] },
                                                                                { id: 2, bar: "2", data: [1, 2, 3, 4] }
                                                                              ],
                                                                              metadata: { count: 5 }
                                                                            })
      end

      it "with sorting" do
        get "/foo?sort=data,-id&page=1&per_page=1"
        puts last_response.body
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq({
                                                                              data: [
                                                                                { id: 4, bar: "4", data: [1, 2, 3, 4] }
                                                                              ],
                                                                              metadata: { count: 5 }
                                                                            })
      end

      it "with special filters" do
        get "/foo?filter[data__contains]=8"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq({
                                                                              data: [
                                                                                { id: 5, bar: "5", data: [1, 2, 3, 8] }
                                                                              ],
                                                                              metadata: { count: 1 }
                                                                            })
      end
    end
  end
end
