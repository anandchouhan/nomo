# This settings are implemented using the Property Bag approach.
# It includes things like privacy and notification settings.
class UserSetting < ApplicationRecord
  validate :valid_key_and_value

  NOTIFICATION_EMAIL_FREQUENCY = "notification_email_frequency".freeze
  NOTIFICATION_EMAIL_FRIEND_REQUESTS = "notification_email_friend_requests".freeze
  NOTIFICATION_EMAIL_FRIEND_CONFIRMATIONS = "notification_email_friend_confirmations".freeze
  NOTIFICATION_EMAIL_FRIEND_FROM_FACEBOOK_JOINS_THE_PLATFORM = "notification_email_friend_from_facebook_joins_the_platform".freeze
  NOTIFICATION_EMAIL_LIKES_IN_MY_ACTIVITY = "notification_email_likes_in_my_activity".freeze
  NOTIFICATION_EMAIL_COMMENTS_ON_MY_ACTIVITY = "notification_email_comments_on_my_activity".freeze
  NOTIFICATION_EMAIL_TRIP_INVITATIONS = "notification_email_trip_invitations".freeze
  NOTIFICATION_EMAIL_COMMENTS_ON_TRIP = "notification_email_comments_on_trip".freeze
  NOTIFICATION_EMAIL_NEW_ACTIVITY_IN_MY_TRIPS = "notification_email_new_activity_in_my_trips".freeze
  NOTIFICATION_EMAIL_UPDATES_OF_YOUR_TRIPS = "notification_email_updates_of_your_trips".freeze
  NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_IN_A_PLACE_THAT_YOU_SCHEDULED = "notification_email_friends_who_will_be_in_a_place_that_you_scheduled".freeze
  NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_COMING_TO_THE_CITY_IM_LIVING_IN = "notification_email_friends_who_will_be_coming_to_the_city_im_living_in".freeze

  # This notifications are hidden notifications while waiting for something to be done.
  NOTIFICATION_EMAIL_COMMENTS_ON_POSTS_WHERE_I_AM_MENTIONED = "notification_email_comments_on_posts_where_i_am_mentioned".freeze
  NOTIFICATION_EMAIL_COMMENTS_AFTER_I_COMMENT_ON_FRIENDS_ACTIVITY = "notification_email_comments_after_i_comment_on_friends_activity".freeze
  NOTIFICATION_EMAIL_MENTIONS_OR_LABELS_ON_TRIP = "notification_email_mentions_or_labels_on_trip".freeze
  NOTIFICATION_EMAIL_CANCELLATION_IN_MY_TRIPS = "notification_email_cancellation_in_my_trips".freeze

  VALID_NOTIFICATION_EMAIL_KEYS = [
    NOTIFICATION_EMAIL_FREQUENCY,
    NOTIFICATION_EMAIL_FRIEND_REQUESTS,
    NOTIFICATION_EMAIL_FRIEND_CONFIRMATIONS,
    NOTIFICATION_EMAIL_FRIEND_FROM_FACEBOOK_JOINS_THE_PLATFORM,
    NOTIFICATION_EMAIL_LIKES_IN_MY_ACTIVITY,
    NOTIFICATION_EMAIL_COMMENTS_ON_MY_ACTIVITY,
    NOTIFICATION_EMAIL_COMMENTS_ON_POSTS_WHERE_I_AM_MENTIONED,
    NOTIFICATION_EMAIL_COMMENTS_AFTER_I_COMMENT_ON_FRIENDS_ACTIVITY,
    NOTIFICATION_EMAIL_TRIP_INVITATIONS,
    NOTIFICATION_EMAIL_MENTIONS_OR_LABELS_ON_TRIP,
    NOTIFICATION_EMAIL_COMMENTS_ON_TRIP,
    NOTIFICATION_EMAIL_NEW_ACTIVITY_IN_MY_TRIPS,
    NOTIFICATION_EMAIL_CANCELLATION_IN_MY_TRIPS,
    NOTIFICATION_EMAIL_UPDATES_OF_YOUR_TRIPS,
    NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_IN_A_PLACE_THAT_YOU_SCHEDULED,
    NOTIFICATION_EMAIL_FRIENDS_WHO_WILL_BE_COMING_TO_THE_CITY_IM_LIVING_IN
  ].freeze

  private

  def valid_key_and_value
    if VALID_NOTIFICATION_EMAIL_KEYS.include?(key)
      valid_values = [
        "on",
        "off"
      ]
      unless valid_values.include?(value)
        errors.add(:value, "is not valid")
      end
    else
      errors.add(:key, "is not valid")
    end
  end
end
