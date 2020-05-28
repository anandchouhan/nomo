class AccommodationsController < ApplicationController
  after_action :create_notifications, only: [:create], if: -> { @accommodation.persisted? }

  def edit
    @accommodation = Accommodation.find(params[:id])
  end

  def create
    @trip_location = TripLocation.find(params[:trip_location_id])
    @accommodation = Accommodation.new(accommodation_params)
    @accommodation.trip_location = @trip_location
    @accommodation.user_id = current_user.id
    if @accommodation.save
      redirect_to trip_trip_location_path(@trip_location.trip, @trip_location), notice: "The accommodation was created"
    else
      redirect_to trip_trip_location_path(@trip_location.trip, @trip_location), notice: "There was an error creating the accommodation"
    end
  end

  def update
    @accommodation = Accommodation.find(params[:id])
    @accommodation.assign_attributes(accommodation_params)

    if @accommodation.save
      redirect_to trip_trip_location_path(@accommodation.trip_location.trip, @accommodation.trip_location), notice: "The accommodation was updated"
    else
      redirect_to trip_trip_location_path(@accommodation.trip_location.trip, @accommodation.trip_location), notice: "There was an error updating the accommodation"
    end
  end

  def destroy
    @accommodation = Accommodation.find(params[:id])
    @accommodation.destroy

    redirect_to trip_trip_location_path(@accommodation.trip_location.trip, @accommodation.trip_location), notice: "The accommodation was deleted"
  end

  private

  def accommodation_params
    params.require(:accommodation).permit(:name,
                                          :arriving_at,
                                          :arriving_at_time,
                                          :departing_at,
                                          :departing_at_time,
                                          :reservation_number,
                                          :location_id,
                                          :description)
  end

  def create_notifications
    message = " created a new accommodation on "
    trip_link = "<a href=#{trip_path(@trip_location.trip)}>#{@trip_location.trip.name}</a>"
    heading = "#{current_user.name} #{message} #{trip_link}"
    mobile_url = @trip_location.custom_email_html(@accommodation, message, "new_accommodation")
    push_message = "#{current_user.name} #{message} #{@trip_location.trip.name}"
    @trip_location.participants.each do |participant|
      unless current_user == participant
        Notification.create(heading: heading, recipient: participant, sender: current_user, notify_type: "new_accommodation", trip_location_id: @trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_NEW_ACTIVITY_IN_MY_TRIPS, context: mobile_url)
        if participant.ios_device_token.present?  
          device_token = participant.ios_device_token
          type = "ios"
        else
          device_token = participant.android_device_token
          type = "android"
        end
        data = { notify_type: "new_accommodation", sender_user_id: current_user.id, recipient_user_id: participant.id, trip_location_id: @trip_location.id, trip_id: @trip_location.trip.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
    end
  end
end
