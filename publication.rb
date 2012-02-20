require 'sinatra'
require 'json'

post '/pull/' do
  # Extract configuration provided by user through BERG Cloud. This will be data defined by the JSON in config_options.json
  config = JSON.parse(params[:config])
  
  # Build edition. Our publication is a picture of the powerpuff girls based on a user choice specified through the params[config]
  @img = "/images/#{config['power_puff_girl']}/#{rand(9)+1}.jpeg"
  @message = "It's #{config['power_puff_girl'].capitalize}!"
  @day = Time.now.strftime('%A')
  erb :hello_world
end

get '/sample/' do
  # Return a sample of our publication.
  config = {'power_puff_girl'=>'buttercup'}
  @img = "/images/#{config['power_puff_girl']}/#{rand(9)+1}.jpeg"
  @message = "It's #{config['power_puff_girl'].capitalize}!"
  @day = Time.now.strftime('%A')
  erb :hello_world
end

post '/validate_config/' do
  # Validate that the user has provided a powerpuff girl that exists. 
  # Of course, they are chosing from a list that we have provided, so it is 
  # unlikely that this will be invialid, but checking anyway.
  content_type :json
    response = {}
    response[:errors] = []
    config = JSON.parse(params[:config])

    if config["power_puff_girl"].nil?
      response[:valid] = false
      response[:errors] << "No powerpuff girl was provided"
    elsif ["buttercup", "blossom", "bubbles"].include?(config["power_puff_girl"].downcase)
      response[:valid] = true
    else 
      response[:valid] = false
      response[:errors] << "Girl #{config["power_puff_girl"]} not valid"
    end
    response.to_json
  
end