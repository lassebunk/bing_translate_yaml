Gem::Specification.new do |s|
  s.name = "bing_translate_yaml"
  s.version = "0.1.8"

  s.author = "Lasse Bunk"
  s.email = "lassebunk@gmail.com"
  s.description = "bing_translate_yaml is a simple Ruby on Rails plugin to translate your YAML files using Bing."
  s.summary = "Simple Ruby on Rails plugin for translating your YAML files using Bing."
  s.homepage = "http://github.com/lassebunk/bing_translate_yaml"
  
  s.add_dependency "bing_translator", "~> 4.0.0"
  s.files = Dir['lib/**/*']
  s.require_paths = ["lib"]
end