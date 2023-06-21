# frozen_string_literal: true

module Verse
  module Http
    module Middleware
      module WithRenderer
        def call(env)
          @output = nil
          call_impl(env)
        end

        def call_impl(env)
          # need to reimplement call.
          raise NotImplementedError
        end

        def rendered?
          !!@output
        end

        def output
          @output
        end

        def render(data, status: 200, content: :json, headers: {})
          return if rendered?

          content_type = \
            case content
            when :json
              "application/json"
            else
              raise "TODO: unsupported content type"
            end

          nheaders = {
            "Content-Type" => content_type
          }.merge(headers)

          @output = Rack::Response.new([data], status, nheaders).finish
        end
      end
    end
  end
end
