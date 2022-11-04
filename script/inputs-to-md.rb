#!/usr/bin/env ruby

require 'yaml'

Dir["**/action.yml"].each do |action|
  lines = []

  lines << "| Name | Description | Default |"
  lines << "| ---- | ----------- | ------- |"

  inputs = YAML.load_file(action)['inputs'].to_a.sort_by(&:first)

  inputs.each do |key, input|
    cols = ["**#{key}**", input['description'], "`#{input['default']}`".gsub('``', '')]
    cols.map! { |col| col.to_s.gsub('|', '\|').gsub("\n", ' ') }
    lines << "| #{cols.join(' | ')} |"
  end

  action_path = action.sub(/action\.yml$/, 'README.md')
  readme = File.read(action_path)
  readme.sub!(/<!-- inputs -->.*<!-- \/inputs -->/m, "<!-- inputs -->\n#{lines.join("\n")}\n<!-- /inputs -->")
  File.write(action_path, readme)
  system("npx prettier --write #{action_path}")
end