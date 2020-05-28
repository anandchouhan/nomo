class Api::EventsController < Api::BaseController
  after_action :create_notifications, only: [:create], if: -> { @event.persisted? }

  def create
    @trip_location = TripLocation.find(params[:trip_location_id])
    create_and_update_location
    if @event.save 
      Analytic.create_analytic(current_user.id, params[:device_type], nil, "event_create", params[:vs], params[:app_version], nil, nil)
      @message = "event successfully created." 
      success_response_params
    else
      @message = @event.errors.full_messages[0]
      failed_response_params
    end
  end

  def update
    create_and_update_location
    if @event.update_attributes(event_params) 
      @message = "event successfully update." 
      success_response_params
    else
      @message = @event.errors.full_messages[0]
      failed_response_params
    end
  end

  def destroy 
    @event = Event.find(params[:event_id])
    @event.destroy
    @message = "Event successfully deleted."
    success_response_params
  end

  private

  def create_and_update_location
    @event = params[:event_id].present? ? Event.find(params[:event_id]) : Event.new(event_params) 
    @location, @message = Location.user_location_for_api(params[:google_place_id]) unless params[:google_place_id].blank?
    @event.location_id = @location.nil? ? nil : @location.id
    @event.end_at = @event.start_at + 1.day
    @event.user_id = current_user.id
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

  def event_params
    params.require(:event).permit(:name,
                                  :start_at,
                                  :start_at_time,
                                  :end_at,
                                  :end_at_time,
                                  :description,
                                  :trip_location_id,
                                  :location_id)
  end

  def create_notifications
    message = " created a new event on "
    user_link = "<a href=#{user_path(current_user)}>#{current_user.name}</a>"
    trip_link = "<a href=#{trip_path(@trip_location.trip)}>#{@trip_location.trip.name}</a>"
    heading = "#{user_link}#{message}#{trip_link}"
    mobile_url = @trip_location.custom_email_html(@event, message, "new_event")
    push_message = "#{current_user.name}#{message}#{@trip_location.trip.name}"
    @trip_location.participants.each do |participant|
      unless current_user == participant
        Notification.create(heading: heading, recipient: participant, sender: current_user, notify_type: "new_event", trip_location_id: @trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_NEW_ACTIVITY_IN_MY_TRIPS, context: mobile_url)
        if participant.ios_device_token.present?  
          device_token = participant.ios_device_token
          type = "ios"
        else
          device_token = participant.android_device_token
          type = "android"
        end
        data = { notify_type: "new_event", sender_user_id: current_user.id, recipient_user_id: participant.id, trip_location_id: @trip_location.id, trip_id: @trip_location.trip.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
    end
  end
end