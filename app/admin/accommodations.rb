ActiveAdmin.register Accommodation do
  permit_params :trip_location_id, :name, :arriving_at, :arriving_at_time, :departing_at, :departing_at_time, :reservation_number, :location_id, :description

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :trip_location_id, as: :select, collection: TripLocation.all.map { |trip_location| ["Trip Name: #{trip_location.trip.name}, City: #{trip_location.location.name}", trip_location.id] }
      f.input :name
      f.input :arriving_at, as: :datepicker
      f.input :arriving_at_time
      f.input :departing_at, as: :datepicker
      f.input :departing_at_time
      f.input :reservation_number
      f.input :location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
      f.input :description
    end

    f.actions
  end
end
