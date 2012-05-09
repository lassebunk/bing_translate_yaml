require 'net/http'
require 'rexml/document'

desc "Translate your YAML files using Bing."
task :translate => :environment do
  @from_locale = ENV["from"]
  @to_locale = ENV["to"]
  @app_id = ENV["app_id"] || "TWwfmo09qPdsxVfnXUMCRHAyk2dGOaodKYVOvbyu3m5Y*"
  
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
  
  File.open(dest_path, 'w') {|f| YAML.dump(out, f) }
  
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
  
  url = "http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=#{@app_id}&text=#{CGI::escape(source)}&from=#{@from_locale}&to=#{@to_locale}"
  xml = Net::HTTP.get_response(URI.parse(url)).body

  doc = REXML::Document.new(xml)
  dest = doc.elements["string"].text.html_safe.gsub("% {", "%{")
  
  puts "#{source} => #{dest}"
  
  dest
end