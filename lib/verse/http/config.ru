# frozen_string_literal: true

require "roda"
require "pry"

RouteNode = Struct.new(
  :children,
  :leafs,
  :args,
  keyword_init: true
) do
  def initialize(children: {}, leafs: {}, args: [])
    super
  end
end

routes = [
  [:get, "/", proc{ "root" }],
  [:get, "/users", proc{ "list users" }],
  [:get, "/users/:id", proc{ |r| "get user #{r.params["id"]}" }],
  [:post, "/users", proc{ "create user" }],
  [:put, "/users/:id", proc{ |r| "update user #{r.params["id"]}" }],
  [:delete, "/users/:id", proc{ |r| "delete user #{r.params["id"]}" }],
  [:get, "/users/info", proc{}],
  [:get, "/posts", proc{}],
  [:get, "/posts/:id", proc{}],
  [:post, "/posts", proc{}],
  [:put, "/posts/:id", proc{ "post with params = #{r.params.inspect}" }],
  [:delete, "/posts/:id", proc{}],
  [:get, "/posts/:post_id/comments", proc{}],
  [:get, "/posts/:post_id/comments/:id", proc{ |r| "post comments with params = #{r.params.inspect}" }],
  [:post, "/posts/:post_id/comments", proc{}],
  [:put, "/posts/:post_id/comments/:id", proc{}],
  [:delete, "/posts/:post_id/comments/:id", proc{}],
  [:get, "/_service", proc{}]
]

def build_route_tree(routes, route_tree = nil)
  route_tree = RouteNode.new

  routes = routes.sort_by do |method, path, _symb|
    path.split("/").map do |part|
      if part.start_with?(":")
        1 # Parameterized part
      else
        0
      end
    end
  end.map do |method, path, symb|
    [method, path.split("/").reject(&:empty?), symb]
  end

  routes.each do |method, parts, symb|
    inject_route(route_tree, parts, method, [], symb)
  end

  generate_body(route_tree)
end

Wildcard = Data.define(:symbol)

def inject_route(node, parts, method, args, cb)

  if parts.empty?
    node.leafs[method] = cb
  else
    key = parts.first

    if key.start_with?(':')
      args << key[1..].to_sym
      key = String
    end

    node_route = (node.children[key] ||= RouteNode.new(args:))

    inject_route(node_route, parts[1..-1], method, args, cb)
  end
end

def generate_body(route_node)
  output = []

  route_node.children.each do |key, node|
    matchers = generate_body(node)

    if key == String
      output << proc do |r|
        puts "on Wildcard"
        r.on String do |value|
          r.params["__path_args__"] << value

          matchers.each{ |m| m.call(r) }
        end
      end
    else
      output << proc do |r|
        puts "on #{key}"
        r.on key do
          matchers.each{ |m| m.call(r) }
        end
      end
    end
  end

  route_node.leafs.each do |method, cb|
    output << proc do |r|
      puts "method #{method}"
      r.send(method) do
        route_node.args.each_with_index do |arg, idx|
          puts "params = #{r.params.inspect}"
          r.params[arg.to_s] = r.params["__path_args__"][idx]
        end

        puts "is cb"
        r.is do
          puts "call #{cb.inspect}"
          cb.call(r)
        end
      end
    end
  end

  output
end

ROUTES = build_route_tree(routes)

class Server < Roda
  route do |r|
    r.params["__path_args__"] = []
    ROUTES.each{ |route| route.call(r) }
  end
end

run Server.freeze.app
