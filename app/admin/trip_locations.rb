ActiveAdmin.register TripLocation do
  permit_params :trip_id,
                :location_id,
                :start_at,
                :end_at,
                accommodations_attributes: %i(id name arriving_at arriving_at_time departing_at departing_at_time reservation_number hotel_address description _destroy),
                travels_attributes: %i(id name reservation_number airline flight_number description departure_location_id departure_airport departing_at departing_at_time arrival_location_id arrival_airport arriving_at arriving_at_time _destroy),
                events_attributes: %i(id name start_at start_at_time end_at end_at_time description location_id _destroy)

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :trip_id, as: :select, collection: Trip.all.map { |trip| ["ID: #{trip.id}, Name: #{trip.name}", trip.id] }
      f.input :location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
      f.input :start_at, as: :datepicker
      f.input :end_at, as: :datepicker
    end

    panel "Participants" do
      table_for trip_location.participants do
        column "ID", :id
        column "Email", :email
        column "Username", :username
        column "Name", :name
      end
    end

    f.inputs "Accommodations" do
      f.has_many :accommodations, heading: false, allow_destroy: true do |accommodation|
        accommodation.input :name
        accommodation.input :arriving_at, as: :datepicker
        accommodation.input :arriving_at_time
        accommodation.input :departing_at, as: :datepicker
        accommodation.input :departing_at_time
        accommodation.input :reservation_number
        accommodation.input :hotel_address
        accommodation.input :description
      end
    end

    f.inputs "Travels" do
      f.has_many :travels, heading: false, allow_destroy: true do |travel|
        travel.input :name
        travel.input :reservation_number
        travel.input :airline
        travel.input :flight_number
        travel.input :description
        travel.input :departure_location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
        travel.input :departure_airport
        travel.input :departing_at, as: :datepicker
        travel.input :departing_at_time
        travel.input :arrival_location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
        travel.input :arrival_airport
        travel.input :arriving_at, as: :datepicker
        travel.input :arriving_at_time
      end
    end

    f.inputs "Events" do
      f.has_many :events, heading: false, allow_destroy: true do |event|
        event.input :name
        event.input :start_at, as: :datepicker
        event.input :start_at_time
        event.input :end_at, as: :datepicker
        event.input :end_at_time
        event.input :description
        event.input :location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
      end
    end

    f.actions
  end
end
