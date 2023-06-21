# frozen_string_literal: true

require File.expand_path("config/boot.rb", __dir__)

run Verse::Http::Server
