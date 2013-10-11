
desc "Translate your YAML files using Bing."
task :translate => :environment do
  
  bing_translate_yaml = BingTranslateYaml.new(ENV)
  puts "Translating..."
  bing_translate_yaml.translate_file
  puts "Done!"
end

