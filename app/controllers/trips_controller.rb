class TripsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show trips_for_location]

  def index
    @trips = current_user.upcoming_trips
  end

  # A redirect is made every time a link is clicked.
  # This is easier than change all links to point to a single trip location.
  def show
    @trip = Trip.find_by_id(params[:id])

    if @trip.nil?
      redirect_to root_url, notice: "Trip not found"
    else
      redirect_to trip_trip_location_path(@trip, @trip.trip_locations.first)
    end
  end

  def new
    @trip = Trip.new
  end

  def edit
    @trip = Trip.find(params[:id])
  end

  def create
    @trip = Trip.create(trip_params)
    referrer = Rails.application.routes.recognize_path(request.referrer)
    referred_by_index = referrer[:controller] == "trips" && referrer[:action] == "index" 

    if @trip.save
      if referred_by_index
        redirect_to trip_path(@trip), notice: "Trip was successfully created."
      else
        redirect_to trip_path(@trip)
      end
    else
      redirect_to trips_url, notice: "Trip was not successfully created. #{@trip.errors.messages}"
    end
  end

  def update
    @trip = Trip.find(params[:id])

    if @trip.update_attributes(trip_params)
      redirect_back fallback_location: root_path, notice: "Trip was successfully updated"
    end
  end

  def destroy
    @trip = Trip.find(params[:id])&.destroy
    redirect_to trips_url, notice: "Trip was successfully destroyed."
  end

  def upvote
    @trip.liked_by current_user
    head :ok
  end

  def downvote
    @trip.downvote_from current_user
    head :ok
  end

  def privacy_settings
    trip = Trip.find(params[:id].to_i)
    trip.privacy_settings = params[:privacy]
    trip.save
    if trip.privacy_settings == params[:privacy]
      respond_to do |format|
        format.json { render json: "success" }
      end
    else
      respond_to do |format|
        format.json { render json: "fail" }
      end
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:user_id,
                                 :description,
                                 :name,
                                 :privacy_settings,
                                 trip_locations_attributes: %i(id location_id start_at end_at _destroy))
  end
end
