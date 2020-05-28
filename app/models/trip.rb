# Accommodations and travels need to be transfered to their own tables.
# It goes agains all good design principles to have trips, accommodations and traves in the same table.
class Trip < ApplicationRecord
  include Rails.application.routes.url_helpers

  acts_as_votable

  belongs_to :user

  has_many :trip_locations, -> { order "start_at ASC" }, dependent: :destroy, inverse_of: :trip
  accepts_nested_attributes_for :trip_locations, allow_destroy: true

  after_create_commit :create_notifications
  after_update_commit :create_notifications

  validates :name, presence: true
  validate :at_least_one_trip_location
  validates_associated :trip_locations

  def can_invite?(user)
    if self.user == user
      true
    else
      case can_invite
      when "MyNetwork"
        true if self.user.friends.include?(user)
      when "Guests"
        true if participants.include?(user)
      when "JustMe"
        true if self.user == user
      end
    end
  end

  def can_see?(user)
    if self.user == user
      true
    else
      case privacy_settings
      when "Public"
        true
      when "FriendsOfFriends"
        true
      when "MyNetwork"
        true if self.user.friends.include?(user)
      when "JustMe"
        true if self.user == user
      end
    end
  end

  def overlapp_and_living_in_city_custom_email_html(trip_location, type, user)
    web_url_trip = "trips/#{trip_location.trip_id}/locations/#{trip_location.id}"
    m_url_trip = "nomo-fomo:/#{web_url_trip}&notify_type=#{type}"
    mobile_url = "During your trip to <a href=/mobile_notification?trip_location_id=#{trip_location.id}&web_url=#{web_url_trip}&mobile_url=#{m_url_trip}>#{trip_location.location.name}</a> you will be in the same city as #{user.name}"
    mobile_url
  end

  # This method is responsible for create notifications to the corresponding users when a trip is created,
  # and when that trip have a trip locations that overlaps a friend's trip location,
  # or when this trip location is the same as a friend's current city.
  # This is the first implementation, and it should be improved to avoid too many hits to the database.
  # rubocop:disable Metrics/PerceivedComplexity
  def create_notifications
    if privacy_settings != "JustMe"
      user.friends.each do |friend|
        friend.trips_participating.each do |friend_trip|
          if self != friend_trip && friend_trip.privacy_settings != "JustMe"
            trip_locations.each do |trip_location|
              if friend_trip_location = TripLocation.where("trip_id = ? AND (start_at, end_at) OVERLAPS (?, ?) AND location_id = ?", friend_trip.id, trip_location.start_at, trip_location.end_at, trip_location.location_id).take
                heading_friend = "During your trip to <a href=#{trip_trip_location_path(friend_trip_location.trip, friend_trip_location)}>#{friend_trip_location.location.name}</a> you will be in the same city as #{user.name}"
                mobile_url = overlapp_and_living_in_city_custom_email_html(friend_trip_location, "overlapping_trip", user)
                Notification.create(heading: heading_friend, recipient: friend, sender: user, notify_type: "overlapping_trip", trip_location_id: friend_trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_IN_A_PLACE_THAT_YOU_SCHEDULED, context: mobile_url)
                push_message = mobile_url.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "").gsub("you will", "from #{friend_trip_location.start_at.strftime('%b %d, %Y')} - #{friend_trip_location.end_at.strftime('%b %d, %Y')} you will")
                if friend.ios_device_token.present?  
                  device_token = friend.ios_device_token
                  type = "ios"
                else
                  device_token = friend.android_device_token
                  type = "android"
                end
                data = { notify_type: "overlapping_trip", sender_user_id: user.id, recipient_user_id: friend.id, trip_location_id: friend_trip_location.id, trip_id: friend_trip_location.trip.id, name: user.name, device_token: device_token, device_type: type, message: push_message }

                Notification.send_push_notification(data) if device_token.present?
                heading_user = "During your trip to <a href=#{trip_trip_location_path(self, trip_location)}>#{trip_location.location.name}</a> from #{trip_location.start_at.strftime('%b %-d')} of #{trip_location.start_at.strftime('%Y')} to #{trip_location.end_at.strftime('%b %-d')} of #{trip_location.end_at.strftime('%Y')} you will be in the same city as #{friend.name}"
                mobile_url = overlapp_and_living_in_city_custom_email_html(trip_location, "overlapping_trip", friend)
                Notification.create(heading: heading_user, recipient: user, sender: friend, notify_type: "overlapping_trip", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_IN_A_PLACE_THAT_YOU_SCHEDULED, context: mobile_url)
                push_message = mobile_url.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "").gsub("you will", "from #{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')} you will")
                if user.ios_device_token.present?  
                  device_token = user.ios_device_token
                  type = "ios"
                else
                  device_token = user.android_device_token
                  type = "android"
                end
                data = { notify_type: "overlapping_trip", sender_user_id: friend.id, recipient_user_id: user.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: user.name, device_token: device_token, device_type: type, message: push_message }
                Notification.send_push_notification(data) if device_token.present?
                break
              end
            end
          end
        end

        trip_locations.each do |trip_location|
          if User.where("id = ? AND location_id = ?", friend.id, trip_location.location_id).exists?
            if user.can_see_location?(friend)
              heading = "During your trip to <a href=#{trip_trip_location_path(self, trip_location)}>#{trip_location.location.name}</a> from #{trip_location.start_at.strftime('%b %-d')} of #{trip_location.start_at.strftime('%Y')} to #{trip_location.end_at.strftime('%b %-d')} of #{trip_location.end_at.strftime('%Y')} you will be in the same city as #{friend.name}"
              mobile_url = overlapp_and_living_in_city_custom_email_html(trip_location, "friend_living_in_city", friend)
              Notification.create(heading: heading, recipient: user, sender: user, notify_type: "friend_living_in_city", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_COMING_TO_THE_CITY_IM_LIVING_IN, context: mobile_url)
              push_message = mobile_url.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "").gsub("you will", "from #{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')} you will")
              if user.ios_device_token.present?  
                device_token = user.ios_device_token
                type = "ios"
              else
                device_token = user.android_device_token
                type = "android"
              end
              data = { notify_type: "friend_living_in_city", sender_user_id: user.id, recipient_user_id: user.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: user.name, device_token: device_token, device_type: type, message: push_message }
              Notification.send_push_notification(data) if device_token.present?
            end
            web_url_trip = "trips/#{id}/locations/#{trip_location.id}"
            m_url_trip = "nomo-fomo:/#{web_url_trip}&notify_type=i_living_in_city"
            mobile_url = "#{user.name} is going to be in your current location of <a href=/mobile_notification?trip_location_id=#{trip_location.id}&web_url=#{web_url_trip}&mobile_url=#{m_url_trip}>#{trip_location.location.name}</a> from #{trip_location.start_at.strftime('%b %-d')} of #{trip_location.start_at.strftime('%Y')} to #{trip_location.end_at.strftime('%b %-d')} of #{trip_location.end_at.strftime('%Y')}"
            heading = "#{user.name} is going to be in your current location of <a href=#{trip_trip_location_path(self, trip_location)}>#{trip_location.location.name}</a> from #{trip_location.start_at.strftime('%b %-d')} of #{trip_location.start_at.strftime('%Y')} to #{trip_location.end_at.strftime('%b %-d')} of #{trip_location.end_at.strftime('%Y')}"
            Notification.create(heading: heading, recipient: friend, sender: user, notify_type: "i_living_in_city", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_COMING_TO_THE_CITY_IM_LIVING_IN, context: mobile_url)
            push_message = "#{user.name} is going to be in your current location of #{trip_location.location.name} from #{trip_location.start_at.strftime('%b %-d')} of #{trip_location.start_at.strftime('%Y')} to #{trip_location.end_at.strftime('%b %-d')} of #{trip_location.end_at.strftime('%Y')}"
            if friend.ios_device_token.present?  
              device_token = friend.ios_device_token
              type = "ios"
            else
              device_token = friend.android_device_token
              type = "android"
            end
            data = { notify_type: "i_living_in_city", sender_user_id: user.id, recipient_user_id: friend.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: user.name, device_token: device_token, device_type: type, message: push_message }
            Notification.send_push_notification(data) if device_token.present?
          end
        end
      end
    else
      user.friends.each do |friend|
        trip_locations.each do |trip_location|
          if User.where("id = ? AND location_id = ?", friend.id, trip_location.location_id).exists? && user.can_see_location?(friend)
            heading = "During your trip to <a href=#{trip_trip_location_path(self, trip_location)}>#{trip_location.location.name}</a> from #{trip_location.start_at.strftime('%b %-d')} of #{trip_location.start_at.strftime('%Y')} to #{trip_location.end_at.strftime('%b %-d')} of #{trip_location.end_at.strftime('%Y')} you will be in the same city as #{friend.name}"
            mobile_url = overlapp_and_living_in_city_custom_email_html(trip_location, "friend_living_in_city", friend)
            Notification.create(heading: heading, recipient: user, sender: user, notify_type: "friend_living_in_city", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_COMING_TO_THE_CITY_IM_LIVING_IN, context: mobile_url)
            push_message = mobile_url.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "").gsub("you will", "from #{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')} you will")
            if user.ios_device_token.present?  
              device_token = user.ios_device_token
              type = "ios"
            else
              device_token = user.android_device_token
              type = "android"
            end
            data = { notify_type: "friend_living_in_city", sender_user_id: user.id, recipient_user_id: user.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: user.name, device_token: device_token, device_type: type, message: push_message }
            Notification.send_push_notification(data) if device_token.present?
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private
  
  def at_least_one_trip_location
    trip_locations.each do |trip_location|
      if !trip_location.marked_for_destruction?
        return
      end
    end

    errors.add(:trip_locations, "must not be empty")
  end
end
