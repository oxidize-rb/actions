require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "maxitest"
  gem "mutex_m"
end

require "maxitest/autorun"
require "json"
require "open3"

ENV["LOL_TIMECOP"] = "#{Time.now.year}-10-31"

describe "fetch-ci-data" do
  describe "stable-ruby-versions" do
    it "works with just 'true'" do
      result = run_with_input("stable-ruby-versions" => "true")

      assert_includes result["stable-ruby-versions"], "head"
    end

    it "can exclude versions" do
      result = run_with_input("stable-ruby-versions" => "exclude: [head]")

      refute_includes result["stable-ruby-versions"], "head"
      assert_includes result["stable-ruby-versions"], "3.1"
    end

    it "gives a helpful error message when YAML is invalid" do
      error = assert_raises { run_with_input("stable-ruby-versions" => "exclude: [head") }

      assert_match "Failed to parse YAML", error.message
    end
  end

  describe "supported-ruby-platforms" do
    it "works with just 'true'" do
      result = run_with_input("supported-ruby-platforms" => "true")

      assert_includes result["supported-ruby-platforms"], "arm64-darwin"
    end

    it "can exclude platforms" do
      result = run_with_input("supported-ruby-platforms" => "exclude: [arm64-darwin]")

      refute_includes result["supported-ruby-platforms"], "arm64-darwin"
      assert_includes result["supported-ruby-platforms"], "x86_64-darwin"
    end

    it "gives a helpful error message when YAML is invalid" do
      error = assert_raises { run_with_input("supported-ruby-platforms" => "exclude: [arm64-darwin") }

      assert_match "Failed to parse YAML", error.message
    end
  end

  describe "supported-rust-targets" do
    it "works with just 'true'" do
      result = run_with_input("supported-rust-targets" => "true")

      assert_includes result["supported-rust-targets"], "aarch64-apple-darwin"
    end

    it "can exclude targets" do
      result = run_with_input("supported-rust-targets" => "exclude: [aarch64-apple-darwin]")

      refute_includes result["supported-rust-targets"], "aarch64-apple-darwin"
      assert_includes result["supported-rust-targets"], "x86_64-apple-darwin"
    end

    it "gives a helpful error message when YAML is invalid" do
      error = assert_raises { run_with_input("supported-rust-targets" => "exclude: [aarch64-apple-darwin") }

      assert_match "Failed to parse YAML", error.message
    end
  end

  describe "input validation" do
    it "has input available" do
      skip "Not in CI" unless ENV["CI"]

      result = JSON.parse(ARGF.read)

      assert_kind_of Hash, result
      assert_equal 3, result.keys.size
    end
  end

  describe "all the things" do
    it "works" do
      result = run_with_input({
        "stable-ruby-versions" => "true",
        "supported-ruby-platforms" => "true",
        "supported-rust-targets" => "true"
      })

      assert_equal 3, result.keys.size
    end
  end

  describe "christmas" do
    it "skips head when it's too hot" do
      result = timecop("YYYY-01-01") { run_with_input({ "stable-ruby-versions" => "true" }) }

      refute_includes result["stable-ruby-versions"], "head"
    end

    it "tests head when christmas is near" do
      result = timecop("YYYY-11-01") { run_with_input({ "stable-ruby-versions" => "true" }) }

      assert_includes result["stable-ruby-versions"], "head"
    end

    it "does nothing when head is explicitly included or excluded" do
      result = timecop("YYYY-04-01") do
        run_with_input({ "stable-ruby-versions" => "only: [head]" })
      end
      assert_includes result["stable-ruby-versions"], "head"

      result = timecop("YYYY-12-24") do
        run_with_input({ "stable-ruby-versions" => "exclude: [head]" })
      end
      refute_includes result["stable-ruby-versions"], "head"
    end
  end

  def run_with_input(hash)
    stdin = hash.to_json
    script = File.expand_path("evaluate.rb", __dir__)
    stdout, stderr, status = Open3.capture3({ "INPUTS" => stdin }.compact, "ruby", script)
    raise stderr unless status.success?
    JSON.parse(stdout)
  end

  def timecop(time)
    old = ENV["LOL_TIMECOP"]
    now = Time.now
    ENV["LOL_TIMECOP"] = time.gsub("YYYY", now.year.to_s).gsub("MM", now.month.to_s).gsub("DD", now.day.to_s)
    yield
  ensure
    ENV["LOL_TIMECOP"] = old
  end
end
