require 'sinatra'
require 'nokogiri'
require 'open-uri'

get '/' do 	
	erb :index
end

get '/edition/' do

  doc = Nokogiri::HTML(open('http://www.parliament.uk/g/rss/news-feed/?pageInstanceId=209&limit=1'))
  
  @headline = doc.xpath('//item/title').text
  @text = doc.xpath('//item/description').text
  @published = doc.xpath('//item/pubdate').text
  
  etag Digest::MD5.hexdigest(@headline+@text+@published)
    
  erb :hello_world
  
end

get '/sample/' do

  @headline = "New members of the Lords announced"
  @text = "Government announces appointment of new life peers"
  @published = "Thu, 01 Aug 2013 11:56:00 GMT"

  etag Digest::MD5.hexdigest(@headline+@text+@published)
  
  erb :hello_world
  
end


