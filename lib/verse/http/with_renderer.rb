# frozen_string_literal: true

module Verse
  module Http
    module WithRenderer
      def rendered?
        !!@output
      end

      def output
        @output
      end

      def render(data, status: 200, content_type: "application/json", headers: {})
        return if rendered?

        nheaders = {
          "Content-Type" => content_type
        }.merge(headers)

        @output = Rack::Response.new([data], status, nheaders).finish
      end
    end
  end
end
