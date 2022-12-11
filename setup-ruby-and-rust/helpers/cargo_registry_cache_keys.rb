# This script generates cache keys for the cargo registry cache. Since the cargo
# registry is a moving target, we generate cache keys based on some recent dates.

cargo_registry_cache_keys = []
prefix = "cr"

(0..12).each do |i|
  cargo_registry_cache_keys << "#{prefix}#{(Time.now - (i * 60 * 60)).strftime("%Y%m%d%H")}"
end

(0..21).each do |i|
  cargo_registry_cache_keys << "#{prefix}#{(Time.now - (i * 60 * 60 * 24)).strftime("%Y%m%d")}"
end

(0..3).each do |i|
  cargo_registry_cache_keys << "#{prefix}#{(Time.now - (i * 60 * 60 * 24 * 30)).strftime("%Y%m")}"
end

cache_key = cargo_registry_cache_keys[0]
restore_keys = cargo_registry_cache_keys[1..-1].join("%0A")

File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
  f.puts "cargo-registry-cache-key=\"#{cache_key}\""
  f.puts "cargo-registry-restore-keys=\"#{restore_keys}\""
end
