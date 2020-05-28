class LocationsController < ApplicationController
  # POST /locations
  # POST /locations.json
  # Creates a new location if doesn't exists using the provided Google Place ID.
  # These locations are used to store frequently accessed information like latitutes, longitudes, addresses, names, etc.
  def create
    @location = Location.where(google_place_id: params[:place_id]).take

    if @location.nil?
      query = {
        key: ENV["GMAPS_API_KEY"],
        place_id: params[:place_id],
        language: "en",
        region: "us"
      }

      uri = URI("https://maps.googleapis.com/maps/api/place/details/json")
      uri.query = URI.encode_www_form(query)

      res = Net::HTTP.get_response(uri)
      result = JSON.parse(res.body)["result"]

      @location = Location.new
      @location.google_place_id = result["place_id"]
      @location.lat = result["geometry"]["location"]["lat"]
      @location.lng = result["geometry"]["location"]["lng"]
      @location.formatted_address = result["formatted_address"]
      @location.name = result["name"]

      if @location.save
        render json: @location, status: :created, location: @exercise
      else
        render json: @location.errors, status: :unprocessable_entity
      end
    else
      render json: @location, status: :ok
    end
  end
end
