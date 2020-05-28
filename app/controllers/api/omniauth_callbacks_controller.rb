class Api::OmniauthCallbacksController < Api::BaseController
  def create
    email = params[:user][:email]
    user_name = params[:user][:name].camelize
    fb_image = params[:user][:profile_image]
    api_uid = params[:user][:facebook_uid]
    oauth_token = params[:user][:oauth_token]
    date_of_birth = params[:user][:date_of_birth]
    oauth_expires_at = params[:user][:oauth_expires_at]
    @user = User.find_by_email(email) || User.find_by_uid(api_uid)
    if @user.nil?
      username = user_name.downcase.gsub(" ", "_")
      password = SecureRandom.hex(3)
      @user = User.new(email: email, name: user_name, username: username, uid: api_uid, fb_image: fb_image, password: password, date_of_birth: date_of_birth, provider: "facebook", oauth_token: oauth_token, oauth_expires_at: oauth_expires_at, vs: params[:vs], device_type: params[:device_type], app_version: params[:app_version], signup_source: "facebook")
      if @user.save
        Analytic.create_analytic(@user.id, params[:device_type], nil, "fb_signup", params[:vs], params[:app_version], nil, nil)
        success_response_params
      else @user.errors.messages.keys.map { |msg| msg if msg == :username }.compact.present?
           username_position = User.all.map { |_user| _user if _user.username.include?(@user.username) }.compact.max_by(&:id).username.split("_").last.to_i + 1
           @user.username.concat("_#{username_position}")
           if @user.save
             success_response_params
           else
             render json: {
               success: false,
               message: @user.errors.full_messages[0]
             }
           end
      end  
    else
      if @user.uid.nil?
        @user.update_attributes(uid: api_uid, oauth_token: oauth_token, oauth_expires_at: oauth_expires_at)
      end
      Analytic.create_analytic(@user.id, params[:device_type], nil, "fb_login", params[:vs], params[:app_version], nil, nil)
      success_response_params
    end
  end

  def check_facebook_id
    @user = User.find_by_uid(params[:facbook_user_id])
    if @user.present?
      Analytic.create_analytic(@user.id, params[:device_type], nil, "fb_login", params[:vs], params[:app_version], nil, nil)
      @user.update_attributes(oauth_token: params[:oauth_token], oauth_expires_at: params[:oauth_expires_at])
      @google_place_id = @user.location.try(:google_place_id)
      @message = "Facebook id is present"
      update_api_token
    else
      render json: {
        success: false,
        message: "Facebook id is not present",
        data: {}
      }
    end
  end

  private

  def success_response_params
    @google_place_id = params[:user][:google_place_id]
    @message = "User Sign in Successfully"
    update_api_token
  end
end
