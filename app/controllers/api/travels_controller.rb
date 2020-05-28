class Api::TravelsController < Api::BaseController
  after_action :create_notifications, only: [:create], if: -> { @travel.persisted? }

  def create
    @trip_location = TripLocation.find(params[:trip_location_id])
    create_and_update_location
    if @travel.save
      Analytic.create_analytic(current_user.id, params[:device_type], nil, "travel_create", params[:vs], params[:app_version], nil, nil)
      @message = "Travel successfully created."
      success_response_params
    else
      @message = @travel.errors.full_messages[0]
      failed_response_params
    end
  end

  def update
    create_and_update_location
    if @travel.update_attributes(travel_params)
      @message = "Travel successfully updated."
      success_response_params
    else
      @message = @travel.errors.full_messages[0]
      failed_response_params
    end
  end

  def destroy
    @travel = Travel.find_by_id(params[:travel_id])
    if @travel.present?
      @travel.destroy
      @message = "Travel successfully destroyed."
      success_response_params
    else
      @message = "Travel not successfully destroyed."
      failed_response_params
    end
  end

  private

  def create_and_update_location
    departure_location = Location.user_location_for_api(params[:departure_location_id]).first.id unless params[:departure_location_id].blank?
    arrival_location = Location.user_location_for_api(params[:arrival_location_id]).first.id unless params[:arrival_location_id].blank?
    params[:travel][:departure_location_id] = departure_location.nil? ? nil : departure_location
    params[:travel][:arrival_location_id] = arrival_location.nil? ? nil : arrival_location
    params[:travel][:departing_at_time] = params[:departing_at].split("-")[1].strip
    params[:travel][:arriving_at_time] = params[:arriving_at].split("-")[1].strip
    @travel = params[:travel_id].present? ? Travel.find(params[:travel_id]) : Travel.new(travel_params) 
    @travel.user_id = current_user.id
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
                                   :trip_location_id,
                                   :arrival_airport,
                                   :arriving_at,
                                   :arriving_at_time)
  end

  def create_notifications
    message = " created a new travel on "
    user_link = "<a href=#{user_path(current_user)}>#{current_user.name}</a>"
    trip_link = "<a href=#{trip_path(@trip_location.trip)}>#{@trip_location.trip.name}</a>"
    heading = "#{user_link}#{message}#{trip_link}"
    mobile_url = @trip_location.custom_email_html(@travel, message, "new_travel")
    push_message = "#{current_user.name}#{message}#{@trip_location.trip.name}"
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

