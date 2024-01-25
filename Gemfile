# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "git@github.com:#{repo}.git" }

# Specify your gem's dependencies in verse-http.gemspec
gemspec

gem "relaxed-rubocop"
gem "rubocop", "~> 1.21"

gem "rack-test"
gem "rspec", "~> 3.0"

gem "bootsnap", "~> 1.16"
gem "pry"
gem "simplecov"
gem "webmock"

gem "verse-core", github: "verse-rb/verse-core", branch: "feature/migrate-to-verse-schema"
gem "verse-schema", github: "verse-rb/verse-core", branch: "master"

gem "rake", "~> 13.0"

gem "mimemagic"

gem "yard"
