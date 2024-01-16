# frozen_string_literal: true

require "spec_helper"

RSpec.describe Verse::Http::Rest, type: :exposition do
  before do
    Verse.on_boot {
      require_relative "./rest_data/sample"
      Spec::Rest::FooExpo.register
    }

    Verse.start(
      :test,
      config_path: "./spec/verse/spec_data/config.yml"
    )

    # Register a few foo records:
    Spec::Rest::FooRepository.clear

    repo = Spec::Rest::FooRepository.new(Verse::Auth::Context[:system])

    repo.create(bar: "1", data: [1, 2, 3, 4], test: "foo")
    repo.create(bar: "2", data: [1, 2, 3, 4], test: "bar")
    repo.create(bar: "3", data: [1, 2, 3, 4], test: "bar")
    repo.create(bar: "4", data: [1, 2, 3, 4], test: "foo")
    repo.create(bar: "5", data: [1, 2, 3, 8], test: "foo")

    Spec::Rest::BarRepository.clear

    repo = Spec::Rest::BarRepository.new(Verse::Auth::Context[:system])

    repo.create(foo_id: 1, value: "foo")
    repo.create(foo_id: 1, value: "bar")
    repo.create(foo_id: 2, value: "foo")
    repo.create(foo_id: 2, value: "bar")
    repo.create(foo_id: 3, value: "foo")
    repo.create(foo_id: 3, value: "bar")
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
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
          {
            data: [
              { id: 1, bar: "1", data: [1, 2, 3, 4] },
              { id: 2, bar: "2", data: [1, 2, 3, 4] }
            ],
            metadata: { count: 5 }
          }
        )
      end

      it "with sorting" do
        get "/foo?sort=data,-id&page=1&per_page=1"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
          {
            data: [
              { id: 4, bar: "4", data: [1, 2, 3, 4] }
            ],
            metadata: { count: 5 }
          }
        )
      end

      it "with special filters" do
        get "/foo?filter[data__contains]=8"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
          {
            data: [
              { id: 5, bar: "5", data: [1, 2, 3, 8] }
            ],
            metadata: { count: 1 }
          }
        )
      end

      it "with included" do
        get "/foo?included[]=bars"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
          {
            data: [
              {
                id: 1,
                bar: "1",
                data: [1, 2, 3, 4],
                bars: [
                  { id: 1, foo_id: 1, value: "foo" },
                  { id: 2, foo_id: 1, value: "bar" }
                ]
              },
              {
                id: 2,
                bar: "2",
                data: [1, 2, 3, 4],
                bars: [
                  { id: 3, foo_id: 2, value: "foo" },
                  { id: 4, foo_id: 2, value: "bar" }
                ]
              },
              {
                id: 3,
                bar: "3",
                data: [1, 2, 3, 4],
                bars: [
                  { id: 5, foo_id: 3, value: "foo" },
                  { id: 6, foo_id: 3, value: "bar" }
                ]
              },
              {
                id: 4,
                bar: "4",
                data: [1, 2, 3, 4],
                bars: []
              },
              {
                id: 5,
                bar: "5",
                data: [1, 2, 3, 8],
                bars: []
              }
            ],
            metadata: { count: 5 }
          }
        )
      end
    end

    context "#show" do
      it "basic call" do
        get "/foo/1"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
          {
            id: 1,
            bar: "1",
            data: [1, 2, 3, 4]
          }
        )
      end

      it "with included" do
        get "/foo/1?included[]=bars"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
          {
            id: 1,
            bar: "1",
            data: [1, 2, 3, 4],
            bars: [
              { id: 1, foo_id: 1, value: "foo" },
              { id: 2, foo_id: 1, value: "bar" }
            ]
          }
        )
      end
    end

    context "#update" do
      it "basic call" do
        patch "/foo/1", { bar: "test" }
        expect(last_response.status).to eq(200)

        expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
          {
            id: 1,
            bar: "test",
            data: [1, 2, 3, 4]
          }
        )
      end
    end

    context "#route_sorting" do
      it "basic call" do
        get "/foo/route_sorting"
        expect(last_response.status).to eq(200)
      end
    end
  end
end
