ActiveAdmin.register Travel do
  permit_params :trip_location_id, :name, :reservation_number, :airline, :flight_number, :description, :departure_location_id, :departure_airport, :departing_at, :departing_at_time, :arrival_location_id, :arrival_airport, :arriving_at, :arriving_at_time

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :trip_location_id, as: :select, collection: TripLocation.all.map { |trip_location| ["Trip Name: #{trip_location.trip.name}, City: #{trip_location.location.name}", trip_location.id] }
      f.input :name
      f.input :reservation_number
      f.input :airline
      f.input :flight_number
      f.input :description
      f.input :departure_location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
      f.input :departure_airport
      f.input :departing_at, as: :datepicker
      f.input :departing_at_time
      f.input :arrival_location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
      f.input :arrival_airport
      f.input :arriving_at, as: :datepicker
      f.input :arriving_at_time
    end

    f.actions
  end
end
