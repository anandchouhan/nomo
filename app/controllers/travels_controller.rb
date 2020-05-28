class TravelsController < ApplicationController
  after_action :create_notifications, only: [:create], if: -> { @travel.persisted? }

  def edit
    @travel = Travel.find(params[:id])
  end

  def create
    @trip_location = TripLocation.find(params[:trip_location_id])
    @travel = Travel.new(travel_params)
    @travel.trip_location = @trip_location
    @travel.user_id = current_user.id
    if @travel.save
      redirect_to trip_trip_location_path(@trip_location.trip, @trip_location), notice: "The travel was created"
    else
      redirect_to trip_trip_location_path(@trip_location.trip, @trip_location), notice: "There was an error creating the travel"
    end
  end

  def update
    @travel = Travel.find(params[:id])
    @travel.assign_attributes(travel_params)

    if @travel.save
      redirect_to trip_trip_location_path(@travel.trip_location.trip, @travel.trip_location), notice: "The travel was updated"
    else
      redirect_to trip_trip_location_path(@travel.trip_location.trip, @travel.trip_location), notice: "There was an error updating the travel"
    end
  end

  def destroy
    @travel = Travel.find(params[:id])
    @travel.destroy

    redirect_to trip_trip_location_path(@travel.trip_location.trip, @travel.trip_location), notice: "The travel was deleted"
  end

  private

  def travel_params
    params.require(:travel).permit(:name,
                                   :reservation_number,
                                   :airline,
                                   :flight_number,
                                   :description,
                                   :departure_location_id,
                                   :departure_airport,
                                   :departing_at,
                                   :departing_at_time,
                                   :arrival_location_id,
                                   :arrival_airport,
                                   :arriving_at,
                                   :arriving_at_time)
  end

  def create_notifications
    message = " created a new travel on "
    trip_link = "<a href=#{trip_path(@trip_location.trip)}>#{@trip_location.trip.name}</a>"
    heading = "#{current_user.name} #{message} #{trip_link}"
    mobile_url = @trip_location.custom_email_html(@travel, message, "new_travel")
    push_message = "#{current_user.name} #{message} #{@trip_location.trip.name}"
    @trip_location.participants.each do |participant|
      unless current_user == participant
        Notification.create(heading: heading, recipient: participant, sender: current_user, notify_type: "new_travel", trip_location_id: @trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_NEW_ACTIVITY_IN_MY_TRIPS, context: mobile_url)
        if participant.ios_device_token.present?  
          device_token = participant.ios_device_token
          type = "ios"
        else
          device_token = participant.android_device_token
          type = "android"
        end
        data = { notify_type: "new_travel", sender_user_id: current_user.id, recipient_user_id: participant.id, trip_location_id: @trip_location.id, trip_id: @trip_location.trip.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
    end
  end
end
