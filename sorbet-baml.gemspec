# frozen_string_literal: true

require_relative "lib/sorbet_baml/version"

Gem::Specification.new do |spec|
  spec.name = "sorbet-baml"
  spec.version = SorbetBaml::VERSION
  spec.authors = ["Vicente Reig Rincon de Arellano"]
  spec.email = ["hey@vicente.services"]

  spec.summary = "Convert Sorbet types to BAML type definitions for LLM prompting"
  spec.description = "A Ruby gem that converts T::Struct and T::Enum to BAML (Boundary AI Markup Language) type definitions. BAML uses 60% fewer tokens than JSON Schema while maintaining type safety."
  spec.homepage = "https://github.com/vicentereig/sorbet-baml"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vicentereig/sorbet-baml"
  spec.metadata["changelog_uri"] = "https://github.com/vicentereig/sorbet-baml/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile docs/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "sorbet-runtime", "~> 0.5"
end
