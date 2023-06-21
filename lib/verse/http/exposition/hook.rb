# frozen_string_literal: true

require "csv"

require_relative "../renderers/binary_renderer"
require_relative "../renderers/stream_renderer"
require_relative "../renderers/json_renderer"
require_relative "../renderers/identity_renderer"

module Verse
  module Http
    module Exposition
      class Hook
        attr_reader :method, :path, :auth

        @renderers = {
          json: Renderers::JsonRenderer,
          binary: Renderers::BinaryRenderer,
          stream: Renderers::StreamRenderer,
          nil: Renderers::IdentityRenderer,
        }

        class << self
          # you can add your own renderers in this list
          attr_reader :renderers
        end

        def initialize(exposition, method, path, auth: :default, renderer: nil)
          renderer ||= exposition.renderer

          root = exposition.http_path || "/"
          root = "/#{root}" unless root[0] == "/"

          # if auth is set to false, nil as auth context.
          @auth = Verse::Http::Auth.get(auth)

          @path = \
            if root[-1] == "/" || path.empty? || path[0] == "/"
              [root, path].join
            else
              [root, path].join("/")
            end

          @method = method
          @renderer = renderer

          raise "invalid http method: `#{method}`" unless %i[get post patch delete put].include?(method)
        end

        def register(exposition_class, block, meta)
          auth = @auth
          renderer = @renderer
          method = @method
          expo_method_name = block.original_name
          hook = self

          Verse::Http::Server.send(method, @path) do
            auth.call(env) do |auth_context|
              safe_params = meta.process_input(params)

              # fetch renderer
              renderer_class = Verse::Exposition::Type::Http.renderers.fetch(renderer) do |value|
                raise "Unknown renderer: `#{value}`"
              end

              renderer_instance = renderer_class.new

              exposition = exposition_class.new(
                auth_context,
                expo_method_name,
                hook,
                env: env,
                unsafe_params: params,
                params: safe_params,
                renderer: renderer_instance
              )

              result = exposition.run do
                metadata = service&.metadata
                metadata[:expo] = "#{exposition_class.name}##{block.original_name}" if metadata
                block.bind(self).call
              end

              renderer_instance.render(result, self)
            end
          end
        end
      end
    end
  end
end
