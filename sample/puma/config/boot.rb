current_env = ENV["APP_ENVIRONMENT"] ||= "development"
require 'dotenv'

Dotenv.load('.env', ".env.#{current_env}")

require "bundler"
Bundler.require(:default, current_env)

ENV["APP_PATH"] = File.expand_path("../..", __FILE__)

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{ENV["APP_PATH"]}/lib")
loader.setup

require_relative "./routes"

Dir[File.join(__dir__, "initializers/**.rb")].each do |file|
  load file
end

Verse.start(:server)
