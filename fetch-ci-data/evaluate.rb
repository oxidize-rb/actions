require "net/http"
require "json"
require "yaml"

def fetch_json(url)
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

def abort_with_error!(message)
  abort "::error::#{message}"
end

def truthy_string?(value)
  return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)
  return false if value.nil?
  return false if value == "false"
  return false if value == ""

  value
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
