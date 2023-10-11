# frozen_string_literal: true

module Spec
  module Rest
    class FooRecord < Verse::Model::Record::Base
      field :id, type: Integer, primary: true

      field :bar, type: String
      field :data, type: Array

      has_many :bars, repository: "Spec::Rest::BarRepository"
    end

    class FooRepository < Verse::Model::InMemory::Repository
      resource "verse-http:foo"
    end

    class BarRecord < Verse::Model::Record::Base
      field :id, type: Integer, primary: true

      field :foo_id, type: Integer
      field :value, type: String

      belongs_to :foo, repository: FooRepository
    end

    class BarRepository < Verse::Model::InMemory::Repository
      resource "verse-http:foo/bar"
    end

    class FooService < Verse::Service::Base
      use_repo FooRepository

      inject Verse::Http::Rest
    end

    class FooExpo < Verse::Exposition::Base
      http_path "/foo"

      use_service FooService

      inject Verse::Http::Rest,
             record: FooRecord,
             extra_filters: [
               "test",
               ["data__contains", ->(x) { x.value(:integer) }]
             ],
             blacklist_filters: ["data"],
             authorized_included: ["bars"]

      # Without proper sorting, this
      # would fail as we have already
      # /foo/:id declared above with the
      # inject method which precede
      # this route.
      expose on_http(:get, "route_sorting") do
      end
      def route_sorting
        nil
      end
    end
  end
end
