# frozen_string_literal: true
#
#  this script inspects the contents of a cross-compiled gem file -- both the files and the gemspec -- to ensure
#  we're packaging what we expect, and that we're not packaging anything we don't expect.
#
require "bundler/inline"
require "net/http"
require "json"

gemfile do
  source "https://rubygems.org"
  gem "ansi"
  gem "builder"
  gem "minitest", "~> 5.0"
  gem "minitest-reporters", "~> 1.6"
  gem "ruby-progressbar"
end

options = {}
OptionParser.new do |opts|
  opts.on("-p", "--platform PLATFORM", "Platform to build for (i.e. x86_64-linux)") do |platform|
    options[:platform] = platform
  end

  opts.on("-r", "--ruby-versions LIST", "List all supported Ruby versions") do |arg|
    vers = arg.split(/[^0-9.]/).map do |v|
      parts = v.split(".")
      parts.join(".")
    end

    options[:ruby_versions] = vers.join(":")
  end
end.parse!

require "yaml"

def usage_and_exit(message = nil)
  puts "ERROR: #{message}" if message
  puts "USAGE: #{File.basename(__FILE__)} -p $PLATFORM [options]"
  exit(1)
end

usage_and_exit if ARGV.include?("-h")
usage_and_exit if options[:platform].nil?

gemfile = "pkg/*-#{options[:platform]}.gem"
gemfile = File.expand_path(gemfile)

gemfile_contents = Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    unless system("tar -xf #{gemfile} data.tar.gz")
      raise "could not unpack gem #{gemfile}"
    end

    %x(tar -ztf data.tar.gz).split("\n")
  end
end

gemspec = Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    unless system("tar -xf #{gemfile} metadata.gz")
      raise "could not unpack gem #{gemfile}"
    end

    YAML.safe_load(
      %x(gunzip -c metadata.gz),
      permitted_classes: [Gem::Specification, Gem::Version, Gem::Dependency, Gem::Requirement, Time, Symbol],
    )
  end
end

puts "---------- gemfile contents ----------"
puts gemfile_contents
puts
puts "---------- gemspec ----------"
puts gemspec.to_ruby
puts

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

def fetch_json(url)
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

describe File.basename(gemfile) do
  let(:all_supported_ruby_versions) do
    fetch_json("https://cache.ruby-lang.org/pub/misc/ci_versions/cruby.json").delete_if { |v| v == "head" }
  end

  let(:actual_supported_ruby_versions) do
    ruby_versions = options[:ruby_versions] || all_supported_ruby_versions
    return all_supported_ruby_versions if ruby_versions.nil?
    ruby_versions.split(":").uniq.delete_if { |v| v == "head" }.map { |ver| ver.split(".").take(2).join(".")  }.sort
  end

  describe "setup" do
    it "gemfile contains some files" do
      actual = gemfile_contents.length
      assert_operator(actual, :>, 0, "expected gemfile to contain more than 0 files")
    end

    it "gemspec is a Gem::Specification" do
      assert_equal(Gem::Specification, gemspec.class)
    end
  end

  describe "native platform" do
    it "does not depend on rb-sys" do
      refute(gemspec.dependencies.find { |d| d.name == "rb-sys" })
    end

    it "contains expected shared library files" do
      actual_supported_ruby_versions.each do |version|
        actual = gemspec.lib_files.find do |file|
          File.fnmatch?("lib/*/#{version}/*.{so,bundle}", file, File::FNM_EXTGLOB)
        end
        assert(actual, "expected to find shared library file for ruby #{version} in lib/#{version}")
      end

      actual = gemspec.lib_files.find do |file|
        File.fnmatch?("lib/?/*.{so,bundle}", file, File::FNM_EXTGLOB)
      end
      refute(actual, "did not expect to find shared library file in lib/")

      actual = gemspec.lib_files.find_all do |file|
        File.fnmatch?("lib/*/*/*.{so,bundle}", file, File::FNM_EXTGLOB)
      end
      assert_equal(
        actual_supported_ruby_versions.length,
        actual.length,
        "did not expect extra shared library files",
      )
    end

    it "sets required_ruby_version appropriately" do
      unsupported_versions = all_supported_ruby_versions - actual_supported_ruby_versions
      actual_supported_ruby_versions.each do |v|
        assert(
          gemspec.required_ruby_version.satisfied_by?(Gem::Version.new(v)),
          "required_ruby_version='#{gemspec.required_ruby_version}' should support ruby #{v}",
        )
      end
      unsupported_versions.each do |v|
        refute(
          gemspec.required_ruby_version.satisfied_by?(Gem::Version.new(v)),
          "required_ruby_version='#{gemspec.required_ruby_version}' should not support ruby #{v}",
        )
      end
    end
  end
end
