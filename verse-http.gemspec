# frozen_string_literal: true

require_relative "lib/verse/http/version"

Gem::Specification.new do |spec|
  spec.name = "verse-http"
  spec.version = Verse::Http::VERSION
  spec.authors = ["Yacine Petitprez"]
  spec.email = ["anykeyh@gmail.com"]

  spec.summary = "HTTP Server and Exposition Endpoint for the Verse framework"
  spec.description = "HTTP Server and Exposition Endpoint for the Verse framework"
  spec.homepage = "https://github.com/verse-rb/verse-http"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/verse-rb/verse-http"
  spec.metadata["changelog_uri"] = "https://github.com/verse-rb/verse-http/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "jwt", "~> 2.7.1"
  spec.add_dependency "sinatra", "~> 3.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
