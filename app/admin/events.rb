ActiveAdmin.register Event do
  permit_params :trip_location_id, :name, :start_at, :start_at_time, :end_at, :end_at_time, :description, :location_id

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :trip_location_id, as: :select, collection: TripLocation.all.map { |trip_location| ["Trip Name: #{trip_location.trip.name}, City: #{trip_location.location.name}", trip_location.id] }
      f.input :name
      f.input :start_at, as: :datepicker
      f.input :start_at_time
      f.input :end_at, as: :datepicker
      f.input :end_at_time
      f.input :description
      f.input :location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
    end

    f.actions
  end
end
