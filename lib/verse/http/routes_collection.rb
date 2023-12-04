# frozen_string_literal: true

module Verse
  module Http
    module RoutesCollection
      extend self

      @routes = []

      def add_route(method, path, &block)
        @routes << [[method, path], block]
      end

      def register!
        order_routes(@routes)

        @routes.each do |(route, callback)|
          Verse::Http::Server.send(*route, &callback)
        end

        @routes.clear # Clear up memory
      end

      def order_routes(input)
        input.sort_by! do |route|
          route.join("|").split("/").map do |part|
            if part.start_with?(":")
              1
            else
              0
            end
          end
        end
      end
    end
  end
end
