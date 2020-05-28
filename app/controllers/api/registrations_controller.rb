class Api::RegistrationsController < Api::BaseController
  # skip_before_action :authenticate_user_from_token!
  def create
    @user = User.find_by_email(user_params[:email])
    if @user.nil?
      @google_place_id = params[:registration][:user][:google_place_id]
      user_params = params[:registration][:user].reject { |key| key == "google_place_id" }
      @user = User.new(user_params.as_json) 
      @user.username = @user.name.gsub(" ", "_").downcase if @user.name.present?
      @user.name = @user.name.split.map(&:capitalize).join(" ")
      @user.current_sign_in_at = Time.now
      @user.last_sign_in_at = @user.current_sign_in_at
      @user.vs = params[:vs]
      @user.device_type = params[:device_type]
      @user.app_version = params[:app_version]
      @user.signup_source = "email_signup"
      if !@user.save
        if @user.errors.messages.keys.map { |msg| msg if msg == :username }.compact.present? && @user.errors.messages.keys.length == 1
          username_position = User.all.map { |_user| _user if _user.username.include?(@user.username) }.compact.max_by(&:id).username.split("_").last.to_i + 1
          @user.username.concat("_#{username_position}")
          @message = "User sign up successfully"
          Analytic.create_analytic(@user.id, params[:device_type], nil, "email_signup", params[:vs], params[:app_version], nil, nil)
          update_api_token
        else
          @user.errors.messages.reject! { |k| k == :username }
          @message = @user.errors.full_messages[0]
          api_token_not_update
        end
      else
        Analytic.create_analytic(@user.id, params[:device_type], nil, "email_signup", params[:vs], params[:app_version], nil, nil)
        @message = "User sign in successfully"
        update_api_token
      end 
    else
      @message = "User already registered"
      api_token_not_update
    end
  end

  def update_facebook_id
    user = User.where("uid = ?", params[:facebook_id]).first
    if user.present?
      @message = "Facebook account already present"
      api_token_not_update
    else
      current_user.update_attributes(uid: params[:facebook_id], oauth_token: params[:oauth_token], oauth_expires_at: params[:oauth_expires_at])
      @user = current_user
      @message = "Successfully connected with facebook"
      update_api_token
    end
  end

  def update
    @user = current_user
    if @user.present?
      @google_place_id = params[:registration][:user][:google_place_id]
      user_params = params[:registration][:user].reject { |key| key == "google_place_id" }
      user_params[:name] = user_params[:name].split.map(&:capitalize).join(" ") if user_params[:name].present?
      if @user.update_attributes(user_params.as_json)
        Analytic.create_analytic(@user.id, params[:device_type], nil, "profile_photo_upload", params[:vs], params[:app_version], nil, nil)
        @message = "User Update Successfully"
        update_api_token
      else
        @message = @user.errors.full_messages[0]
        api_token_not_update
      end
    else
      @message = "Invalid Token"
      api_token_not_update
    end
  end

  def analytics 
    analytic = Analytic.where("device_token = ? AND device_type = ? AND analytic_type = ?", params[:device_token], params[:device_type], params[:analytic_type]).first
    if analytic.present?
      render json: {
        success: true,
        message: "Already added in app."
      }
    else
      analytic = Analytic.create_analytic(nil, params[:device_type], params[:device_token], params[:analytic_type], params[:vs], params[:app_version], nil, nil)
      if analytic.present?
        render json: {
          success: true,
          message: "Analytic successfully saved."
        }
      else
        @message = analytic.errors.full_messages[0]
        api_token_not_update
      end
    end
  end

  private

  def api_token_not_update
    render json: {
      success: false,
      message: @message
    }
  end
 
  def user_params
    params.require(:user).permit(:email, :password, :date_of_birth, :name, :picture, :password_confirmation, :bio)
  end
end

