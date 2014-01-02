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
   
  cal = Nokogiri::XML(open('http://services.parliament.uk/calendar/all.rss'))
  @events = []
  
  cal.xpath('//parlycal:event')[0..4].each { |item|
    myevent = {}
    myevent[:house] = item.at_xpath('parlycal:house/text()').text
    myevent[:chamber] = item.at_xpath('parlycal:chamber/text()').text
    myevent[:date] = item.at_xpath('parlycal:date/text()').text
    myevent[:starttime] = item.at_xpath('parlycal:startTime/text()').text if item.at_xpath('parlycal:startTime/text()')
    myevent[:committee] = item.at_xpath('parlycal:comittee/text()').text if item.at_xpath('parlycal:comittee/text()')
    myevent[:location] = item.at_xpath('parlycal:location/text()').text if item.at_xpath('parlycal:location/text()')
    myevent[:subject] = item.at_xpath('parlycal:subject/text()').text.gsub(' -', '.') if item.at_xpath('parlycal:subject/text()')
    myevent[:nicetime] = DateTime.parse(myevent[:date].to_s + ' ' + myevent[:starttime].to_s).strftime("%a, %e %b %Y %H:%M:%S")
    @events << myevent
#     @events.reverse!
    }
  
  etag Digest::MD5.hexdigest(@headline+@text+@published)
    
  erb :hello_world
  
end

get '/sample/' do

  @headline = "New members of the Lords announced"
  @text = "Government announces appointment of new life peers"
  @published = "Thu, 01 Aug 2013 11:56:00 GMT"
  @events = {}
  
  etag Digest::MD5.hexdigest(@headline+@text+@published)
  
  erb :hello_world
  
end


