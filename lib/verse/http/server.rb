# frozen_string_literal: true

require "sinatra"

require_relative "middleware/error_handler"
require_relative "middleware/logger_handler"

module Verse
  module Http
    class Server < Sinatra::Base
      CONTENT_TYPE_REGEXP = /^((\w|[.-])+)\+((\w|[.-])+)$/i

      before do
        content_type = request.env["CONTENT_TYPE"]

        if content_type =~ %r{\Amultipart/form-data}
          self.params = request.env["rack.request.form_hash"]
        else
          # Parse JSON Body and store in the params hash.
          request.body&.rewind

          body_content = request.body&.read || ""

          first, second = content_type&.split("/")

          if second&.=~(CONTENT_TYPE_REGEXP)
            second = second[CONTENT_TYPE_REGEXP, 3]
          end

          body_params = \
            case [first, second]
            when ["application", "json"]
              begin
                JSON.parse(body_content)
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

        set :host_authorization, { permitted_hosts: [], allow_if: ->(env) { true } }
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
        JSON.generate(
          {
            service: Verse.service_name,
            id: Verse.service_id
          }
        )
      end
    end
  end
end
