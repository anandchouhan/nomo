class ChangeUserSettingKeyHometown < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      UPDATE user_settings
        SET key = 'notification_email_friends_who_will_be_coming_to_the_city_im_living_in'
        WHERE key = 'notification_email_friends_who_will_be_coming_to_my_hometown'
    SQL
  end
end
