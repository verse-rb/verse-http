module Spec
  module Rest
    class FooRecord < Verse::Model::Record::Base
      field :bar, type: String
      field :data, type: Array
    end

    class FooRepository < Verse::Model::InMemory::Repository
    end

    class FooService < Verse::Service::Base

    end

    class FooExpo < Verse::Exposition::Base
      http_path "/foo"

      use_service FooService

      inject Verse::Http::Rest,
        record: FooRecord,
        extra_filters: ["test"],
        blacklist_filters: ["data"]

    end
  end
end
