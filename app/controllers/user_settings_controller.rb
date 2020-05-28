class UserSettingsController < ApplicationController
  def update
    # Does a bulk create or update of user settings.
    # If the setting doesn't exist with the provided ID, it creates a new one.
    # If the setting does exist, it updates this setting with the new value.
    user_id = params[:user_id]
    user_settings = params[:user_settings]

    user_settings.each do |_, setting_param|
      user_setting = nil

      if setting_param[:id].nil?
        user_setting = UserSetting.new
        user_setting.user_id = user_id
        user_setting.key = setting_param[:key]
      else
        user_setting = UserSetting.find(setting_param[:id])
      end

      if UserSetting::VALID_NOTIFICATION_EMAIL_KEYS.include?(setting_param[:key])
        value = setting_param[:value]
        user_setting.value = !value.nil? && value == "on" ? value : "off"
      else
        user_setting.value = setting_param[:value]
      end

      user_setting.save
    end

    redirect_back fallback_location: "/me/settings"
  end
end
