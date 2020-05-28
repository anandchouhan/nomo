class OnboardingsController < ApplicationController
  respond_to :html, :json

  def welcome
    @fb_freinds = current_user.fb_freinds
  end

  def update
    @user = User.find_by_id(params[:id])
    @user.update(user_params)
    @user.update(current_step: "step2")
  end

  def step2
    current_user.update(current_step: "step3")
  end

  def create
    @trip = Trip.create(trip_params)
    current_user.update(current_step: "tour")
    
    if @trip.save
      redirect_to activities_path(onboard: true), notice: "Trip was successfully created."
    else
      redirect_to activities_path, notice: "Trip was not successfully created. #{@trip.errors.messages}"
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :name, :email, :encrypted_password, :salt, :provider, :uid, :oauth_token, :oauth_expires_at, :role, :hometown_id, :location_id, :phone_number, :website, :bio, :twitter_id, :facebook_id, :instagram_id, :linked_in_id, :youtube_id, :blog_id)
  end

  def trip_params
    params.require(:trip).permit(:user_id,
                                 :description,
                                 :name,
                                 :privacy_settings,
                                 trip_locations_attributes: %i(id location_id start_at end_at _destroy))
  end
end
