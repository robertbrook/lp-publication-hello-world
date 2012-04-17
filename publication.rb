require 'sinatra'
require 'json'

# Define some greetings for different times of the day in different languages
greetings = {"english" => ["Good morning", "Hello", "Good evening"], 
    "french" => ["Bonjour", "Bonjour", "Bonsoir"], 
    "german" => ["Guten morgen", "Hallo" "Guten abend"], 
    "spanish" =>["Buenos d&#237;as", "Hola", "Buenas noches"], 
    "portuguese" => ["Bom dia", "Ol&#225;", "Boa noite"], 
    "italian" => ["Buongiorno", "ciao", "Buonasera"], 
    "swedish"=>["God morgon", "Hall&#229;", "God kv&#228;ll"]}


# Prepares and returns this edition of the publication
#
# == Parameters:
# lang
#   The language for the greeting. The subscriber will have picked this from the values defined in meta.json.
# name
#   The name of the person to greet. The subscriber will have entered their name at the subscribe stage.
#
# == Returns:
# HTML/CSS edition with etag. This publication changes the greeting depending on the time of day. It is using UTC to determine the greeting.
#
get '/edition/' do
  # Extract configuration provided by user through BERG Cloud. These options are defined by the JSON in meta.json.
  language = params['lang'];
  name = params['name'];
  
  i = 1
  case Time.now.utc.hour
  when 4..11
    i = 0
  when 12..17
    i = 1
  when 18..24
  when 0..3
    i = 2
  end

  # Set the etag to be this content
  etag Digest::MD5.hexdigest(language+name)
  
  # Build this edition.
  @greeting = "#{greetings[language][i]}, #{name}"
  
  erb :hello_world
end


# Returns a sample of the publication. Triggered by the user hitting 'print sample' on you publication's page on BERG Cloud.
#
# == Parameters:
#   None.
#
# == Returns:
# HTML/CSS edition with etag. This publication changes the greeting depending on the time of day. It is using UTC to determine the greeting.
#
get '/sample/' do
  language = 'english';
  name = 'Little Printer';
  @greeting = "#{greetings[language][0]}, #{name}"
  # Set the etag to be this content
  etag Digest::MD5.hexdigest(language+name)
  erb :hello_world
end


# Returns a sample of the publication. Triggered by the user hitting 'print sample' on you publication's page on BERG Cloud.
#
# == Parameters:
# :config
#   params[:config] contains a JSON array of responses to the options defined by the fields object in meta.json.
#   in this case, something like:
#   params[:config] = ["name":"SomeName", "lang":"SomeLanguage"]
#
# == Returns:
# a response json object.
# If the paramters passed in are valid: {"valid":true}
# If the paramters passed in are not valid: {"valid":false,"errors":["No name was provided"], ["The language you chose does not exist"]}"
#
post '/validate_config/' do
  response = {}
  response[:errors] = []
  
  # Extract config from POST
  user_settings = JSON.parse(params[:config])

  # If the user did not fill in the lang option:
  if user_settings['lang'].nil?
    response[:valid] = false
    response[:errors].push('Please select a language from the select box.')
  end
  
  if user_settings['name'].nil?
    response[:valid] = false
    response[:errors].push('Please enter your name into the name box.')
  end
  
  if greetings.include?(user_settings['lang'].downcase)
    response[:valid] = true
  else 
    # Given that that select box is populated from a list of languages that we have defined this should never happen.
    response[:valid] = false
    response[:errors].push("We couldn't find the language you selected (#{config["lang"]}) Please select another")
  end
  
  content_type :json
  response.to_json
end