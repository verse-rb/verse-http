# frozen_string_literal: true

module Spec
  module Rest
    class FooRecord < Verse::Model::Record::Base
      field :id, type: Integer

      field :bar, type: String
      field :data, type: Array
    end

    class FooRepository < Verse::Model::InMemory::Repository
      resource "verse-http:foo"
    end

    class BarRecord < Verse::Model::Record::Base
      field :id, type: Integer
      field :foo_id, type: Integer
      field :value, type: String

      belongs_to :foo, repository: FooRepository
    end

    class BarRepository < Verse::Model::InMemory::Repository
      resource "verse-http:bar"
    end

    class FooService < Verse::Service::Base
      use_repo FooRepository

      inject Verse::Http::Rest

      def activate(id)
        record = repo.find!(id)

        # do something with record
        repo.update!(record.id, bar: "active")
      end
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
             blacklist_filters: ["data"]

      expose on_http(:get, "activate/:id") do
        input do
          required(:id).filled(:integer)
        end
      end
      def activate
        service.active(params[:id])
      end
    end
  end
end
