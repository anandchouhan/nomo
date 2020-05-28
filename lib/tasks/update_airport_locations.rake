require "csv"
require "json"

namespace :update_airport_locations do
  desc "imports the airport codes"
  task import: :environment do
    airport_data = {}

    puts "Alright, let's load up some airports y'all"
    airport_data_count = 0

    CSV.foreach("#{Rails.root}/vendor/assets/javascripts/airport-codes/airports.dat") do |row|
      # puts row.inspect
      airport_data[row[3]] = [] if airport_data[row[3]].blank?
      airport_data[row[3]] << {
        name: row[1],
        city: row[2],
        country: row[3],
        iata: row[4],
        icao: row[5],
        latitude: row[6],
        longitude: row[7],
        altitude: row[8],
        timezone: row[9],
        dst: row[10]
      }

      airport_data_count += 1
    end

    puts "That is #{airport_data_count} airports, pretty sweet."
    airport_data_count = 0

    File.open("vendor/assets/javascripts/airport-codes/airports.json", "w").puts JSON.generate(airport_data)

    airport_data.each do |key, val|
      country = Country.find_or_create_by name: key
      val.each do |airport|
        airport[:country] = country
        airport[:city] = City.find_or_create_by(name: airport[:city], country: country)
        Airport.find_or_create_by airport unless airport[:iata].blank?
      end
    end
  end
end
