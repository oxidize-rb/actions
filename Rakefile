require "yaml"

def generate_table(action, replace_key, defaults)
  lines = []
  if defaults
    lines << "| Name | Description | Default |"
    lines << "| ---- | ----------- | ------- |"
  else
    lines << "| Name | Description |"
    lines << "| ---- | ----------- |"
  end

  items = YAML.load_file(action)[replace_key].to_a.sort_by(&:first)

  items.each do |key, item|
    cols = ["**#{key}**", item["description"]]
    cols << "`#{item["default"]}`".gsub("``", "") if defaults
    cols.map! { |col| col.to_s.gsub("|", '\|').tr("\n", " ") }
    lines << "| #{cols.join(" | ")} |"
  end

  action_path = action.sub(/action\.yml$/, "readme.md")
  readme = File.read(action_path)
  readme.sub!(/<!-- #{replace_key} -->.*<!-- \/#{replace_key} -->/m, "<!-- #{replace_key} -->\n#{lines.join("\n")}\n<!-- /#{replace_key} -->")
  File.write(action_path, readme)
end

task :readme do
  Dir["**/action.yml"].each do |action|
    generate_table(action, "inputs", true)
    generate_table(action, "outputs", false)

    action_path = action.sub(/action\.yml$/, "readme.md")
    sh("npx prettier --write #{action_path}")
  end
end

namespace :release do
  desc "Tag a new release, and update all of the semver references"
  task :publish do
    sh "git diff --exit-code"

    current_version = File.read("VERSION").strip
    new_version = ENV["VERSION"]

    if new_version.nil?
      printf "Current version is %s. Enter new version: ", current_version
      new_version = STDIN.gets.strip
    end

    abort "Invalid version: #{new_version}" unless new_version.match?(/\A\d+\.\d+\.\d+\z/)

    if current_version >= new_version
      abort "New version must be greater than current version"
    end

    major, _minor, _patch = new_version.split(".")

    File.write("VERSION", new_version)

    sh "git add VERSION"
    sh "git commit -m 'Bump to #{new_version}'"
    sh "git tag v#{new_version}"
    sh "git tag -f v#{major}"
    sh "git push"
    sh "git push --tags --force"
    sh "gh release create v#{new_version} --generate-notes"
  end
end
