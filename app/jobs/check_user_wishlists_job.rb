class CheckUserWishlistsJob < ApplicationJob
  queue_as :default

  def perform(user)
    circle_trips = Trip.where(user_id: user.circles.includes(:circle_users).pluck("circle_users.user_id"))
    user.wishlists.active.each do |wl|
      trips = circle_trips.where(location_id: wl.location_id, start_at: wl.start_at, end_at: wl.end_at)
      if trips.count.positive?
        trips.each do |trip|
          previous_activity = user.activities.find_by(object_id: trip.id, object_klass: trip.class.superclass.name)
          unless previous_activity
            "#{trip.user.name} is going to be in #{trip.location.city_signature_or_formatted_address} from #{wl.start_at.to_time.strftime('%b %d')} to #{wl.end_at.to_time.strftime('%b %d')}"
            # Activity.create(heading: heading, user: user, object_id: trip.id, object_klass: trip.class.superclass.name, objects: {trip.class.name => trip})
          end
        end
      end
    end
  end
end
