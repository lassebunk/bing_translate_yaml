require 'spec_helper'

describe BingTranslateYaml do
  
  before :all do
    @options = {}
    @options['from'] = 'en'
    @options['to'] = "es"
    @options['client_id'] = ENV['bing_client_id']
    @options['client_secret'] = ENV['bing_client_secret']
    @options['add_path'] = "_dictionary"
    
    @english = {
        'en'=> {
          'hello'=> "hello",
          'goodbye'=> "goodbye"
        }
      }
    @spanish = {
        'es'=> {
          'hello'=> "Hola",
          'goodbye'=> "Adiós"
        }
      }
  end
  
  it "should translate one yaml file into another language" do
    
    
    File.open("./source.yml", "w") do |f|
      f.write(@english.to_yaml)
    end
    
    bing_translate_yaml = BingTranslateYaml.new(@options)
    #overriding default path for testing
    bing_translate_yaml.source_path = "./source.yml"
    bing_translate_yaml.destination_path = "./destination.yml"
    puts "Translating..."
    bing_translate_yaml.translate_file
    puts "Done!"    
    bing_translate_yaml.load_destination.should == @spanish["es"]    
    
    File.delete('./source.yml')
    File.delete('./destination.yml')
  end
  
  
  it "should translate one string to another language" do
    
    bing_translate_yaml = BingTranslateYaml.new(@options)
    hello = bing_translate_yaml.translate_string("Hello")
    hello.should == "Hola"
    
  end
  
end