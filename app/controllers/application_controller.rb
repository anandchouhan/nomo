require "openssl"
require "json"
require "base64"
require "cgi"

class ApplicationController < ActionController::Base
  include ApplicationHelper
  layout :layout_by_resource

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_employee_emails

  helper_method :public_view?
  helper_method :user_signed_in?

  protect_from_forgery
  before_action :authenticate_user!
  before_action :set_cookies
  before_action :current_profile
  before_action :viewed_walkthrough, if: :user_signed_in?
  helper_method :current_profile

  def viewed_walkthrough
    current_user.update_attributes(viewed_walkthrough: params[:walkthrough].to_i) if params[:walkthrough]
  end

  def set_current_user
    if user_signed_in?
      @user = current_user
    end
  end

  def initialize
    super
    @public_view = false
  end

  def public_view?
    @public_view
  end

  def set_employee_emails
    @employee_emails = [
      "gusavila92@gmail.com",
      "bryanxm@gmail.com",
      "dannyangelosanto@gmail.com",
      "tarah.laurent@gmail.com",
      "adelaidasofiA@yahoo.com",
      "diazroaa@gmail.com",
      "pauldavidperry@gmail.com",
      "jswalsh84@gmail.com",
      "charlizexx@gmail.com"
    ]
  end

  def error_render_method
    respond_to do |type|
      type.xml { render template: "errors/error_404", status: 404 }
      type.all { head :ok, status: 404 }
    end
    true
  end

  def contact_us
    ContactUsMailer.contact_us_notification(contact_us_params).deliver_later
    redirect_back(fallback_location: root_path)
  end

  def current_profile
    gon.appId = ENV["FACEBOOK_APP_ID"]
    if user_signed_in?
      @notifications_count = current_user.notifications.order(id: :asc).unread.count
    end
  end

  def extract_mentions(text)
    extract_mentioned_screen_names(text)
  end

  def proccess_mentions(mentionable_object)
    mentioned_usernames = extract_mentions mentionable_object.text
    mentionable_object.remove_mentions
    mentioned_usernames.each do |username|
      mentioned_user = User.where("lower(username) = ?", username.downcase).first
      mentionable_object.add_mention mentioned_user unless mentioned_user.nil?
    end
  end

  private

  def contact_us_params
    params.require(:contact_us).permit(:name, :email, :message)
  end

  def set_cookies
    if user_signed_in?
      # User ID is used to authenticate a WebSocket connection using ActionCable
      cookies.encrypted[:user_id] = current_user.id
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i(name email date_of_birth))
  end

  def layout_by_resource
    if devise_controller?
      "landing"
    else
      "application"
    end
  end
end
