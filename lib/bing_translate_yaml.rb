require 'railtie'
require 'hash_subtraction'
require 'net/http'
require 'rexml/document'
require 'bing_translator'
require 'yaml'

class BingTranslateYaml
  
  attr_accessor :translator_connection, :source_path, :destination_path
  
  def initialize(options={})
    @from_locale = options["from"]
    raise "need to specify from=<locale>" unless @from_locale
  
    @to_locale = options["to"]
    raise "need to specify to=<locale>" unless @to_locale
  
    @client_id = options["client_id"]
    raise "need to specify client_id=<Your Bing Azure Client ID>" unless @client_id
  
    @client_secret = options["client_secret"]
    raise "need to specify client_secret=<Your Bing Azure Client Secret>" unless @client_secret
  
    @add_path = options["add_path"] || nil
    set_paths
  end
  
  def set_paths
    @source_path = "#{Rails.root}/config/locales/#{@from_locale}#{@add_path}.yml"
    @destination_path = "#{Rails.root}/config/locales/#{@to_locale}#{@add_path}.yml"
  end
  
  def load_source
    if File.exists?(@source_path)
      source_yaml = YAML::load(File.open(@source_path))
      source_yaml ? source_yaml[@from_locale] || {} : {}
    else
      {}
    end
  end
  
  def load_destination
    if File.exists?(@destination_path)
      dest_yaml = YAML::load(File.open(@destination_path))
      dest_yaml ? dest_yaml[@to_locale] || {} : {}
    else
      {}
    end
  end

  def translate_file
    #extending with HashSubtraction allows for removal of duplicate keys removing the same key values from one hash from another. 
    #This is used to keep us from re-translating already translated text.
    source = load_source
    source.extend(HashSubtraction)
    
    dest = load_destination
  
    #remove already translated keys and then recursively translate the hash
    translated = translate_hash(source.remove_duplicate_keys(dest)) 
  
    #add already translated text back to the hash.
    out = { @to_locale => translated.deep_merge(dest) }
    File.open(@destination_path, 'w') {|f| f.write out.to_yaml }
  end

  def translate_string(source)
    return "" unless source
  
    dest = translator.translate(source, :from => @from_locale, :to => @to_locale)
    puts "#{source} => #{dest}"
  
    dest
  end
  
  private
  
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

  def translator
    @translator_connection ||= BingTranslator.new(@client_id, @client_secret)
  end
end