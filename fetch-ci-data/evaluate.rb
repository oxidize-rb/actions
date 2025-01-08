require "net/http"
require "json"
require "yaml"
require "date"

def fetch_json(url, attempt = 0)
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
rescue => e
  if attempt < 3
    sleep 1
    log(:warn, "Failed to fetch #{url}: #{e.message}, retrying (attempt #{attempt + 1})")
    fetch_json(url, attempt + 1)
  else
    abort_with_error! "Failed to fetch #{url}: #{e.message}"
  end
end

def abort_with_error!(message)
  abort "::error::#{message}"
end

def log(level, message)
  warn "::#{level}:: #{message}"
end

def truthy_string?(value)
  return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)
  return false if value.nil?
  return false if value == "false"
  return false if value == ""

  value
end

def days_til_christmas
  today = ENV.fetch("LOL_TIMECOP") { Date.today.to_s }
  today = Date.parse(today)
  christmas = Date.new(today.year, 12, 25)
  christmas = Date.new(today.year + 1, 12, 25) if today > christmas
  (christmas - today).to_i
end

def fetch_rb_sys_github_action_matrix
  url = "https://raw.githubusercontent.com/oxidize-rb/rb-sys/main/data/derived/github-actions-matrix.json"
  @fetch_rb_sys_github_action_matrix ||= fetch_json(url)
end

def fetch_stable_ruby_versions(inputs)
  return unless (opts_string = truthy_string?(inputs.delete("stable-ruby-versions")))

  opts = parse_yaml_opts(opts_string)
  versions = fetch_json("https://cache.ruby-lang.org/pub/misc/ci_versions/cruby.json")
  versions.reject! { |version| opts["exclude"].include?(version) } if opts["exclude"]
  versions.select! { |version| opts["only"].include?(version) } if opts["only"]
  explicit_ruby_head = (opts.fetch("only", []) + opts.fetch("exclude", [])).include?("head")

  unless explicit_ruby_head
    if days_til_christmas < 60
      log(:info, "🎄 It's beginning to look a lot like Christmas, so we're testing against ruby-head")
    else
      countdown = days_til_christmas - 60
      log(:notice, "🎅 Heads up, this CI job will begin testing ruby-head in #{countdown} days") if countdown <= 90
      versions -= ["head"]
    end
  end

  # See https://github.com/rake-compiler/rake-compiler-dock/blob/c4e7dc390e0757891ad8c7898953f87a35c957dc/History.md?plain=1#L53
  # for more information on v3.3.5.
  versions.each_with_index { |version, i| versions[i] = "3.3.5" and break if version == "3.3" }
  log(:info, "Selected Ruby versions: #{versions.join(', ')}")

  {"stable-ruby-versions" => versions}
end

def parse_yaml_opts(str)
  return str if str.is_a?(Hash)
  return {} if str.is_a?(FalseClass) || str.is_a?(TrueClass)
  return {} if str.nil? || str.empty?
  return {} if str == "null" || str == "false" || str == "true"

  YAML.safe_load(str)
rescue => e
  abort_with_error! "Failed to parse YAML: #{e.message}"
end

def fetch_supported(inputs, key)
  return unless (opts_string = truthy_string?(inputs.delete("supported-#{key}s")))

  opts = parse_yaml_opts(opts_string)
  matrix = fetch_rb_sys_github_action_matrix
  plats = matrix["include"].map { |entry| entry[key] }
  plats.reject! { |plat| opts["exclude"].include?(plat) } if opts["exclude"]
  plats.select! { |plat| opts["only"].include?(plat) } if opts["only"]

  {"supported-#{key}s" => plats}
end

def evaluate_query(inputs)
  result = {}

  result.merge!(fetch_stable_ruby_versions(inputs) || {})
  result.merge!(fetch_supported(inputs, "ruby-platform") || {})
  result.merge!(fetch_supported(inputs, "rust-target") || {})

  abort_with_error! "Unknown inputs: #{inputs.keys}" unless inputs.keys.empty?

  result
end

inputs = JSON.parse(ENV.fetch("INPUTS"))

puts evaluate_query(inputs).to_json
