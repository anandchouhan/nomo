class AddDefaultSettingsToExistingUsers < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.settings[:privacy] ||= {
        find_by_email_permission: :public,
        find_by_phone_permission: :public,
        friend_request_permission: :public
      }
      user.settings[:notifications] ||= {
        email: {
          activity_on_trips: false,
          cancellation_of_trips: false,
          comments_on_activity: false,
          comments_on_commented_activity: false,
          comments_on_tagged_activity: false,
          friends_comming_to_hometown: false,
          friends_confirmations: false,
          friends_near_me_in_future: false,
          friends_requests: false,
          friends_visiting_location: {
            active: false,
            location_id: nil
          },
          invitations_to_trip: false,
          likes_in_activity: false,
          mentions_on_trips: false,
          update_of_trips: false
        },
        frequency: :weekly,
        proximity: {
          active: false,
          distance: 10,
          units: "km"
        }
      }
    end
  end
end
