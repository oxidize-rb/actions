# This script generates cache keys for the cargo registry cache. Since the cargo
# registry is a moving target, we generate cache keys based on some recent dates.

require "securerandom"

cargo_registry_cache_keys = []
prefix = "cr"

8.times do |i|
  cargo_registry_cache_keys << "#{prefix}#{(Time.now - (i * 60 * 60 * 24)).strftime("%Y%m%d")}"
end

2.times do |i|
  cargo_registry_cache_keys << "#{prefix}#{(Time.now - (i * 60 * 60 * 24 * 30)).strftime("%Y%m")}"
end

cache_key = cargo_registry_cache_keys[0]
restore_keys = cargo_registry_cache_keys[1..-1].join("\n")

# raise 'too many keys' if restore_keys.split("\n").size > 10
# raise 'not enough keys' if restore_keys.split("\n").size < 10

def set_output(key, value)
  eol = $/
  delimiter = "ghadelimiter_#{SecureRandom.uuid}"

  "#{key}<<#{delimiter}#{eol}#{value}#{eol}#{delimiter}#{eol}"
end

File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
  f.write set_output("cargo-registry-cache-key", cache_key)
  f.write set_output("cargo-registry-restore-keys", restore_keys)
end
