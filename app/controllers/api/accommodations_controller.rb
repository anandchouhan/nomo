class Api::AccommodationsController < Api::BaseController
  after_action :create_notifications, only: [:create], if: -> { @accommodation.persisted? }
  def create  
    @trip_location = TripLocation.find_by_id(params[:trip_location_id])
    create_and_update_location
    if @accommodation.save 
      Analytic.create_analytic(current_user.id, params[:device_type], nil, "accommodation_create", params[:vs], params[:app_version], nil, nil)
      @message = "Accommodation successfully created." 
      success_response_params
    else
      @message = @accommodation.errors.full_messages[0]
      failed_response_params
    end
  end

  def update
    create_and_update_location
    if @accommodation.update_attributes(accommodation_params) 
      @message = "Accommodation successfully updated."
      success_response_params
    else
      @message = @accommodation.errors.full_messages[0]
      failed_response_params
    end
  end

  def destroy 
    @accommodation = Accommodation.find(params[:accommodation_id])
    @accommodation.destroy
    @message = "Accommodation successfully deleted."
    success_response_params
  end

  private

  def create_and_update_location
    @accommodation = params[:accommodation_id].present? ? Accommodation.find(params[:accommodation_id]) : Accommodation.new(accommodation_params) 
    @location, @message = Location.user_location_for_api(params[:google_place_id]) unless params[:google_place_id].blank?
    @accommodation.location_id = @location.nil? ? nil : @location.id
    @accommodation.user_id = current_user.id
  end

  def success_response_params
    render json: {
      success: true,
      message: @message
    }
  end

  def failed_response_params
    render json: {
      success: false,
      message: @message
    }
  end

  def accommodation_params
    params.require(:accommodation).permit(:name,
                                          :arriving_at,
                                          :arriving_at_time,
                                          :departing_at,
                                          :departing_at_time,
                                          :reservation_number,
                                          :trip_location_id,
                                          :description,
                                          :user_id)
  end

  def create_notifications
    message = " created a new accommodation on "
    user_link = "<a href=#{user_path(current_user)}>#{current_user.name}</a>"
    trip_link = "<a href=#{trip_path(@trip_location.trip)}>#{@trip_location.trip.name}</a>"
    heading = "#{user_link}#{message}#{trip_link}"
    mobile_url = @trip_location.custom_email_html(@accommodation, message, "new_accommodation")
    push_message = "#{current_user.name}#{message}#{@trip_location.trip.name}"
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