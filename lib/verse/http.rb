# frozen_string_literal: true

require "verse/core"

module Verse
  module Http
  end
end

require_relative "http/version"
require_relative "http/plugin"

Dir["#{__dir__}/**/*.rb"].sort.each do |file|
  next if file[__dir__.size..] =~ %r{^/(?:cli|spec)} # do not load CLI nor specs files unless told otherwise.

  require_relative file
end