class HomeController < ApplicationController
  require 'net/http'
  require 'json'
  require 'prawn'
  require 'prawn/table' # Add this line

  def first
  end

  def index
    fetch_aqi_data
  end

  def search
    @city = params[:city]
    fetch_aqi_data
  
    respond_to do |format|
      format.html { render :index }
    end
  
  rescue URI::InvalidURIError => e
    handle_error("Invalid city name")
  rescue StandardError => e
    handle_error("An error occurred: #{e.message}")
  end

  def generate_pdf
    @city = params[:city]
    @forecast = JSON.parse(params[:forecast]) if params[:forecast].present?
  
    respond_to do |format|
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Forecast for #{@city}:", size: 20, style: :bold
        pdf.move_down 10
        data = [['Date', 'O3 Max', 'O3 Min']]
        @forecast['o3'].each do |day|
          data << [day['day'], day['max'], day['min']]
        end
        pdf.table(data, header: true)
        send_data pdf.render, filename: "forecast_data.pdf", type: 'application/pdf'
      end
    end
  end
  
  def show
    @city = params[:city]
    @forecast = params[:forecast]
  end

  private
  
  def fetch_aqi_data
    url = "https://api.waqi.info/feed/#{@city}/?token=38222fc5a41c1127b1d565af52ee686a3bafdb60"
    uri = URI(url)
  
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
    
      if data.key?('data') && data['data'].key?('aqi') && data['data'].key?('forecast') && data['data']['forecast'].key?('daily')
        @aqi = data['data']['aqi']
        @forecast = data['data']['forecast']['daily']
      else
        handle_error("Unexpected data format in API response")
      end
    else
      handle_error("Failed to fetch data from the API")
    end
  end

  def search_cities(query)
    # Method to search for cities based on the query
  end

  def handle_error(message)
    @aqi = nil
    @forecast = nil
    flash.now[:error] = message
  end
end
