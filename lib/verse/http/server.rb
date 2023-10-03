# frozen_string_literal: true

require "sinatra"

require_relative "middleware/error_handler"
require_relative "middleware/logger_handler"

module Verse
  module Http
    class Server < Sinatra::Base
      before do
        # Parse JSON Body and store in the params hash.
        request.body.rewind

        if request.env["CONTENT_TYPE"] == "application/json"
          body_params = \
            if request.body.size
              begin
                JSON.parse(request.body.read)
              rescue JSON::ParserError => e
                raise Verse::Error::BadRequest, e.message
              end
            else
              {}
            end

          # If the body is not a hash, we merge it into the params hash
          # under the special key _body
          self.params = if body_params.is_a?(Hash)
                          body_params.merge(params)
                        else
                          params.merge({ _body: body_params })
                        end
        else
          # Store the body as string into the params hash
          self.params = params.merge({ _body: request.body.read })
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
