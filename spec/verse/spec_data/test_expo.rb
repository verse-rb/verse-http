# frozen_string_literal: true

class TestExpo < Verse::Exposition::Base
  http_path "/test"

  expose on_http(:get, "/identity", renderer: Verse::Http::Renderer::Identity)
  def endpoint_identity
    auth_context.mark_as_checked!
    "hello world"
  end

  expose on_http(:get, "/no_auth", auth: nil)
  def endpoint_no_auth
    "hello world"
  end

  expose on_http(:get, "/error", auth: nil)
  def error
    raise "error !"
  end

  expose on_http(:post, "/no_content", auth: nil)
  def no_content
    server.no_content
  end

  expose on_http(:post, "/custom_type", auth: nil)
  def custom_type
    unsafe_params
  end

end
