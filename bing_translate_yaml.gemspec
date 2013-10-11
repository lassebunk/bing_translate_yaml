Gem::Specification.new do |s|
  s.name = "bing_translate_yaml"
  s.version = "1.1.1"

  s.author = "Lasse Bunk, Kelly Mahan"
  s.email = "lassebunk@gmail.com"
  s.description = "bing_translate_yaml is a simple Ruby on Rails plugin to translate your YAML files using Bing."
  s.summary = "Simple Ruby on Rails plugin for translating your YAML files using Bing."
  s.homepage = "http://github.com/lassebunk/bing_translate_yaml"
  
  s.add_dependency "bing_translator", "~> 4.0.0"
  s.add_dependency "rails"
  s.add_dependency "hash_subtraction"
  s.add_development_dependency "rspec"
  s.add_development_dependency 'rake'
  s.files = Dir['lib/**/*']
  s.require_paths = ["lib"]
end