class HomeController < ApplicationController
  def index
    require 'net/http'
    require 'json'
    url = 'https://api.waqi.info/feed/here/?token=38222fc5a41c1127b1d565af52ee686a3bafdb60'
    uri = URI(url)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    @aqi = data['data']['aqi']
  end

  def search
    @city = params[:city]

    if @city.present?
      response = HTTParty.get("https://api.waqi.info/feed/#{@city}/?token=38222fc5a41c1127b1d565af52ee686a3bafdb60")
      if response.success? && response.parsed_response['status'] == 'ok'
        @aqi_value = response.parsed_response['data']['aqi']
      else
        @aqi_value = nil
      end
      @cities = search_cities(@city)
    else
      @aqi_value = nil
      @cities = []
      
    end
    
    render :index
  end
  
  private
  
  def search_cities(query)
    # Implement a method to search for cities based on the query
    # This can be done by filtering a list of cities based on whether their names contain the query
    # For simplicity, you can create a static list of cities here or fetch it from a database
    cities = [
      { name: 'Mumbai', aqi: "click to get AQI" },
      { name: 'Delhi', aqi: "click to get AQI"  },
      { name: 'Bangalore', aqi: "click to get AQI"  },
      # Add more cities as needed
    ]
    cities.select { |city| city[:name].downcase.include?(query.downcase) }
  end
end
