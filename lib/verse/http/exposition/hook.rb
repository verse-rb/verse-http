# frozen_string_literal: true

require "csv"

module Verse
  module Http
    module Exposition
      # A hook is a single endpoint on the http server
      # @see Verse::Http::Exposition::Extension#on_http
      # @see Verse::Exposition::Base#expose
      class Hook < Verse::Exposition::Hook::Base
        attr_reader :http_method, :path, :auth, :renderer

        # Create a new hook
        # Used internally by the `on_http` method.
        # @see Verse::Http::Exposition::Extension#on_http
        def initialize(exposition, http_method, path, auth: :default, renderer: nil)
          super(exposition)

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

          @http_method = http_method.to_sym
          @renderer = renderer

          raise "invalid http method: `#{@http_method}`" unless %i[get post patch delete put].include?(@http_method)
        end

        # :nodoc:
        def register_impl
          hook = self

          Verse::Http::Server.send(http_method, @path) do
            hook.auth.call(env) do |auth_context|
              safe_params = hook.metablock.process_input(params)

              # fetch renderer
              renderer_class = Verse::Http::Renderer[hook.renderer] do |value|
                raise "Unknown renderer: `#{value}`"
              end

              renderer_instance = renderer_class.new

              exposition = hook.create_exposition(
                auth_context,
                env: env,
                unsafe_params: params,
                params: safe_params,
                renderer: renderer_instance,
                server: self,
              )

              result = exposition.run do
                hook.method.bind(self).call
              end

              hook.metablock.process_output(result)
              renderer_instance.render(result, self)
            end
          end
        end
      end
    end
  end
end
