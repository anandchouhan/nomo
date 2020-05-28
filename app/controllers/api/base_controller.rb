class Api::BaseController < ApplicationController
  include ActionController::ImplicitRender
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
 
  protected
 
  def current_user
    if token_from_request.blank? && (params[:action] == "default_settings_data" || params[:controller] == "api/omniauth_callbacks" || params[:controller] == "api/sessions" || params[:controller] == "api/registrations" || params[:controller] == "api/passwords")
      nil
    else
      authenticate_user_from_token!
    end  
  end
  alias_method :devise_current_user, :current_user
 
  def user_signed_in?
    !current_user.nil?
  end
  alias_method :devise_user_signed_in?, :user_signed_in?
 
  # rubocop:disable Style/RescueModifier
  def authenticate_user_from_token!
    if claims && user = User.find_by(email: claims[0]["user"])
      @current_user = user
    else
      data = { notify_type: "token_expire", sender_user_id: 0, recipient_user_id: 0, trip_location_id: 0, trip_id: 0, name: "", device_token: token_from_request, device_type: "", message: "" }
      NotificationChannel.broadcast_to("notifications", data: data)
      render json: {
        success: false,
        message: "Invalid token"
      }
      puts ""
    end
  end
 
  def claims
    JWT.decode(token_from_request, "YOURSECRETKEY", true) rescue nil
  end
  # rubocop:enable Style/RescueModifier
  
  def jwt_token(user)
    # 2 Weeks
    expires = Time.now.to_i + (3600 * 24 * 14)
    JWT.encode({ user: user.email, exp: expires }, "YOURSECRETKEY", "HS256")
  end
 
  def token_from_request
    # Accepts the token either from the header or a query var
    # Header authorization must be in the following format
    # Authorization: Bearer {yourtokenhere}
    auth_header = request.headers["Authorization"] 
    token = auth_header
    if token.to_s.empty?
      token = request.parameters["token"]
    end
    token
  end

  def update_api_token
    @location, @msg = Location.user_location_for_api(@google_place_id) if @google_place_id.present?
    @auth_token = jwt_token(@user)
    if (params[:controller] == "api/registrations" && ["create", "update"].include?(params[:action])) || (params[:controller] == "api/sessions") || (params[:controller] == "api/omniauth_callbacks")
      @user.update_attributes(jwt_token: @auth_token, location_id: @location.id, current_sign_in_at: Time.now, last_sign_in_at: @user.current_sign_in_at) 
    end
    render json: {
      success: true,
      message: @message,
      data: { id: @user.id, email: @user.email, name: @user.name, city: @user.location.try(:name), bio: @user.bio, token: @user.jwt_token, picture: @user.picture, fb_image: @user.fb_image, place_id: @user.location.try(:google_place_id), facebook_id: @user.uid.nil? ? " " : @user.uid }
    }
  end
end