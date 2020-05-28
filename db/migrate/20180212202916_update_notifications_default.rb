class UpdateNotificationsDefault < ActiveRecord::Migration
  def change
    notifications = {
      email: {
        activity_on_trips: true,
        cancellation_of_trips: true,
        comments_on_activity: true,
        comments_on_commented_activity: true,
        comments_on_tagged_activity: true,
        friends_comming_to_hometown: true,
        friends_confirmations: true,
        friends_near_me_in_future: true,
        friends_requests: true,
        friends_visiting_location: {
          active: true,
          location_id: nil,
        },
        invitations_to_trip: true,
        likes_in_activity: true,
        mentions_on_trips: true,
        update_of_trips: true,
      },
      frequency: "automatically",
      notified_trip_ids: [],
      proximity: {
        active: true,
        distance: 50,
        units: "km",
      },
    }
    User.all.each do |u|
      u.settings[:notifications] = notifications
    end
  end
end
