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
end
