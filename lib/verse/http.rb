# frozen_string_literal: true

require "verse/core"

module Verse
  module Http
  end
end

require_relative "http/version"
require_relative "http/plugin"

Dir["#{__dir__}/**/*.rb"].sort.each do |file|
  # do not load CLI nor specs files unless told otherwise.
  next if file =~ /(cli|spec)\.rb$/ ||
          file[__dir__.size..] =~ %r{^/(?:cli|spec)}

  require_relative file
end

# Extend the Verse::Exposition::Base with the HTTP DSL
Verse::Exposition::Base.extend(Verse::Http::Exposition::Extension)
