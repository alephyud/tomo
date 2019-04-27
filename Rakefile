require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

task default: %i[test rubocop]

RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

namespace :bump do
  task all: %w[bundler ruby year]

  task :bundler do
    travis = IO.read(".travis.yml")
    travis[/bundler -v (\S+)/, 1] = Gemfile.bundler_version
    IO.write(".travis.yml", travis)
  end

  task :ruby do
    gemspec = IO.read("tomo.gemspec")
    gemspec[/ruby_version = ">= (.*)"/, 1] = RubyVersions.lowest_supported
    IO.write("tomo.gemspec", gemspec)

    rubocop = IO.read(".rubocop.yml")
    rubocop[/TargetRubyVersion: (.*)/, 1] = RubyVersions.lowest_supported_minor
    IO.write(".rubocop.yml", rubocop)

    travis = YAML.safe_load(open(".travis.yml"))
    travis["rvm"] = RubyVersions.latest_supported_patches + ["ruby-head"]
    IO.write(".travis.yml", YAML.dump(travis))
  end

  task :year do
    license = IO.read("LICENSE.txt")
    license[/\(c\) (\d+)/, 1] = Date.today.year.to_s
    IO.write("LICENSE.txt", license)
  end
end

require "date"
require "open-uri"
require "yaml"

module Gemfile
  class << self
    def bundler_version
      lock_file[/BUNDLED WITH\n   (\S+)$/, 1]
    end

    private

    def lock_file
      @_lock_file ||= IO.read("Gemfile.lock")
    end
  end
end

module RubyVersions
  class << self
    def lowest_supported
      "#{lowest_supported_minor}.0"
    end

    def lowest_supported_minor
      latest_supported_patches.first[/\d+\.\d+/]
    end

    def latest_supported_patches
      patches = [versions[:stable], versions[:security_maintenance]].flatten
      patches.map(&Gem::Version.method(:new)).sort.map(&:to_s)
    end

    private

    def versions
      @_versions ||= begin
        yaml = open(
          "https://raw.githubusercontent.com/ruby/www.ruby-lang.org/master/_data/downloads.yml"
        )
        YAML.safe_load(yaml, symbolize_names: true)
      end
    end
  end
end
