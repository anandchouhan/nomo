class Location < ApplicationRecord
  validates_presence_of :name

  # City signature must be removed because locations can contain place is general, not only cities.
  # To avoid breaking something, this workaround is used.
  def city_signature_or_formatted_address
    formatted_address.blank? ? city_signature : formatted_address
  end

  def picture_url
    "https://s3.us-east-2.amazonaws.com/nomofomo-assets/static/images/user.png"
  end

  def self.user_location_for_api(place_id)
    @location = where(google_place_id: place_id).take
    if @location.nil?
      query = {
        key: ENV["GMAPS_API_KEY"],
        place_id: place_id,
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
        [@location, true]
      else
        [@location.errors, false]
      end
    else
      [@location, true]
    end
  end
end
