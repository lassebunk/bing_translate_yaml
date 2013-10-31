require 'net/http'
require 'rexml/document'
require 'bing_translator'
require 'yaml'

desc "Translate your YAML files using Bing."
task :translate => :environment do
  @from_locale = ENV["from"]
  raise "need to specify from=<locale>" unless @from_locale
  
  @to_locale = ENV["to"]
  raise "need to specify to=<locale>" unless @to_locale

  @client_id = ENV["client_id"]
  raise "need to specify client_id=<Your microsoft client_id>" unless @client_id
  
  @client_secret = ENV["client_secret"]
  raise "need to specify client_secret=<Your microsoft client_secret>" unless @client_secret
  
  puts "Translating..."
  
  source_path = "#{Rails.root}/config/locales/#{@from_locale}.yml"
  dest_path = "#{Rails.root}/config/locales/#{@to_locale}.yml"
  
  if File.exists?(source_path)
    source_yaml = YAML::load(File.open(source_path))
    source = source_yaml ? source_yaml[@from_locale] || {} : {}
  else
    source = {}
  end

  if File.exists?(dest_path)
    dest_yaml = YAML::load(File.open(dest_path))
    dest = dest_yaml ? dest_yaml[@to_locale] || {} : {}
  else
    dest = {}
  end
  
  source = source_yaml ? source_yaml[@from_locale] || {} : {}
  dest = dest_yaml ? dest_yaml[@to_locale] || {} : {}
  
  translated = translate_hash(source)
  
  out = { @to_locale => translated.deep_merge(dest) }

  File.open(dest_path, 'wb') {|f|  f.write out.to_yaml }
  
  puts "Done!"
end

def translate_hash(yaml)
  dest = yaml.dup
  
  yaml.keys.each do |key|
    source = yaml[key]
    
    if source.is_a?(Symbol)
      translated = source
    elsif source.is_a?(String)
      translated = translate_string(source)
    elsif source.is_a?(Hash)
      translated = translate_hash(source)
    elsif source.is_a?(Array)
      translated = translate_array(source)
    else
      translated = ""
    end
    
    dest[key] = translated
  end
  
  dest
end

def translate_array(array)
  out = []
  array.each do |source|
    if source.is_a?(Symbol)
      out << source
    else
      out << translate_string(source)
    end
  end
  out
end

def translate_string(source)
  return "" unless source
  
  dest = translator.translate(source, :from => @from_locale, :to => @to_locale)
  
  puts "#{source} => #{dest}"
  
  dest
end

def translator
  @translator ||= BingTranslator.new @client_id, @client_secret
end