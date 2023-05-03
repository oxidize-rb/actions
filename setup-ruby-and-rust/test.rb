require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "maxitest"
end

require "maxitest/autorun"
require "json"

OUTPUTS = begin
  JSON.parse(ENV.fetch("SETUP_OUTPUTS"))
rescue KeyError
  raise if ENV["CI"]

  {
    "ruby-platform" => RbConfig::CONFIG["arch"],
    "ruby-prefix" => RbConfig::CONFIG["prefix"],
    "base-cache-key-level-1" => "v0__test__it"
  }
end

describe "setup-ruby-and-ruby" do
  describe "output validation" do
    OUTPUTS.each do |key, value|
      next unless key.include?("cache-key")

      it "has a valid value for #{key.inspect}" do
        assert value !~ /__\s*__/
        assert !value.start_with?("__")
        assert !value.end_with?("__")
        assert value.start_with?("v")

        assert value.split("__").uniq.size == value.split("__").size
      end
    end

    it "has has a valid ruby-platform" do
      assert_equal RbConfig::CONFIG["arch"], OUTPUTS["ruby-platform"]
    end

    it "has has a valid ruby-prefix" do
      assert_equal RbConfig::CONFIG["prefix"], OUTPUTS["ruby-prefix"]
    end
  end
end
