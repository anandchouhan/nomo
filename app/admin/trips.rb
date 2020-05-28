ActiveAdmin.register Trip do
  permit_params :user_id,
                :name,
                :description,
                trip_locations_attributes: %i(id location_id start_at end_at _destroy)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :user_id, as: :select, collection: User.all.map { |user| [user.name, user.id] }
      f.input :name
      f.input :description
    end

    f.inputs "Trip Locations" do
      f.has_many :trip_locations, heading: false, allow_destroy: true do |trip_location|
        trip_location.input :location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
        trip_location.input :start_at, as: :datepicker
        trip_location.input :end_at, as: :datepicker
      end
    end

    f.actions
  end
end
