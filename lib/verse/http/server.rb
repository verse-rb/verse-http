# frozen_string_literal: true

require "sinatra"

require_relative "middleware/error_handler"
require_relative "middleware/logger_handler"

module Verse
  module Http
    class Server < Sinatra::Base
      CONTENT_TYPE_REGEXP = /^(\w|\-)+(\+(\w|\-))(;.+)$/i.freeze

      before do
        # Parse JSON Body and store in the params hash.
        request.body.rewind

        body_content = request.body.read

        content_type = request.env["CONTENT_TYPE"]

        first, second = content_type&.split("/")

        if second&.=~(CONTENT_TYPE_REGEXP)
          second = second[CONTENT_TYPE_REGEXP, 3]
        end

        body_params = \
          case [first, second]
          when ["application", "json"]
            begin
              JSON.parse(request.body.read)
            rescue JSON::ParserError => e
              raise Verse::Error::BadRequest, e.message
            end
          else
            body_content
          end

        # If the body is not a hash, we merge it into the params hash
        # under the special key _body
        self.params = \
          if body_params.is_a?(Hash)
            body_params.merge(params)
          else
            params.merge({ _body: body_params })
          end

        # Default output to application/json.
        content_type "application/json" unless content_type
      end

      use Verse::Http::Middleware::ErrorHandler
      use Verse::Http::Middleware::LoggerHandler

      def self.remove_middleware(&block)
        instance_variable_get(:@middleware).reject!(&block)
      end

      configure do
        enable :show_exceptions
      end

      not_found do
        raise Verse::Error::NotFound
      end

      def no_content
        response.status = 204
        nil
      end

      # show some service information
      get "/_service" do
        {
          service: Verse.service_name,
          id: Verse.service_id
        }.to_json
      end
    end
  end
end
