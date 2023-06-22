class TestExpo < Verse::Exposition::Base

  http_path "/test"

  expose on_http(:get, "/identity", renderer: :identity)
  def endpoint_identity
    "hello world"
  end

  expose on_http(:get, "/no_auth", auth: :none)
  def endpoint_no_auth
    "hello world"
  end

end