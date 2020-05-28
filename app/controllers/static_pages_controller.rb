class StaticPagesController < ApplicationController
  layout "landing"
  skip_before_action :authenticate_user!
  before_action :check_signed_in, only: [:index]

  def index; end

  def about; end

  def terms_and_conditions; end

  def privacy_policy; end 

  def reset_mobile_password
    @token = params[:reset_password_token]
  end

  def mobile_notification
    @web_url = params[:web_url]
    @mobile_url = params[:mobile_url]
  end

  private

  def check_signed_in
    redirect_to activities_path if signed_in?
  end
end
