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

  action_path = action.sub(/action\.yml$/, "README.md")
  readme = File.read(action_path)
  readme.sub!(/<!-- #{replace_key} -->.*<!-- \/#{replace_key} -->/m, "<!-- #{replace_key} -->\n#{lines.join("\n")}\n<!-- /#{replace_key} -->")
  File.write(action_path, readme)
end

task :readme do
  Dir["**/action.yml"].each do |action|
    generate_table(action, "inputs", true)
    generate_table(action, "outputs", false)

    action_path = action.sub(/action\.yml$/, "README.md")
    system("npx prettier --write #{action_path}")
  end
end
