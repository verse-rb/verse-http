# frozen_string_literal: true

require "bootsnap"
Bootsnap.setup(cache_dir: "tmp/cache")

require "simplecov"
SimpleCov.start do
  add_filter do |file|
    file.filename !~ /lib/
  end
end

require "pry"
require "bundler"

Bundler.require

require "verse/http"
require "verse/http/spec"

def silent
  return unless (logger = Verse.logger)

  level = logger.level
  logger.fatal!

  yield
ensure
  logger.level = level
end

RSpec.configure do |config|
  # Add user fixture
  Verse::Http::Spec::HttpHelper.add_user("user", :user)

  # set a dummy role for testing
  Verse::Auth::Context[:user] = %w[
    users.read.*
    users.write.*
    verse-http:foo.*.*
  ]

  whitelist = ["localhost", "127.0.0.1"]
  WebMock.disable_net_connect!(allow: whitelist)

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.include_chain_clauses_in_custom_matcher_descriptions = true
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
