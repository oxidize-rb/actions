require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "maxitest"
end

require "maxitest/autorun"
require "json"

OUTPUTS = JSON.parse(ENV.fetch("SETUP_OUTPUTS"))

describe "setup-ruby-and-ruby" do
  describe "output validation" do
    it "has has a valid ruby-platform" do
      assert_equal RbConfig::CONFIG["arch"], OUTPUTS["ruby-platform"]
    end

    it "has has a valid ruby-prefix" do
      assert_equal RbConfig::CONFIG["prefix"], OUTPUTS["ruby-prefix"]
    end
  end
end
