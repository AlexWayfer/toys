# frozen_string_literal: true

lib = ::File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "toys/version"

::Gem::Specification.new do |spec|
  spec.name = "toys"
  spec.version = ::Toys::VERSION
  spec.authors = ["Daniel Azuma"]
  spec.email = ["dazuma@gmail.com"]

  spec.summary = "A configurable command line tool"
  spec.description =
    "Toys is a configurable command line tool. Write commands in Ruby using" \
    " a simple DSL, and Toys will provide the command line executable and" \
    " take care of all the details such as argument parsing, online help," \
    " and error reporting. Toys is designed for software developers, IT" \
    " professionals, and other power users who want to write and organize" \
    " scripts to automate their workflows. It can also be used as a" \
    " replacement for Rake, providing a more natural command line interface" \
    " for your project's build tasks."
  spec.license = "MIT"
  spec.homepage = "https://github.com/dazuma/toys"

  spec.files = ::Dir.glob("lib/**/*.rb") + ::Dir.glob("builtins/**/*.rb") +
               ::Dir.glob("*.md") + ::Dir.glob("docs/*.md") +
               ::Dir.glob("bin/*") + ::Dir.glob("share/*") + [".yardopts"]
  spec.required_ruby_version = ">= 2.3.0"
  spec.require_paths = ["lib"]

  spec.bindir = "bin"
  spec.executables = ["toys"]

  spec.add_dependency "toys-core", "= #{::Toys::VERSION}"

  spec.add_development_dependency "did_you_mean", "~> 1.0"
  spec.add_development_dependency "highline", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "minitest-focus", "~> 1.1"
  spec.add_development_dependency "minitest-rg", "~> 5.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rdoc", "~> 6.1.2"
  spec.add_development_dependency "redcarpet", "~> 3.5" unless ::RUBY_PLATFORM == "java"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 0.79.0"
  spec.add_development_dependency "yard", "~> 0.9.24"

  if spec.respond_to?(:metadata)
    spec.metadata["changelog_uri"] = "https://github.com/dazuma/toys/blob/master/toys/CHANGELOG.md"
    spec.metadata["source_code_uri"] = "https://github.com/dazuma/toys"
    spec.metadata["bug_tracker_uri"] = "https://github.com/dazuma/toys/issues"
    spec.metadata["documentation_uri"] = "https://dazuma.github.io/toys/gems/toys/v#{::Toys::VERSION}"
  end
end
