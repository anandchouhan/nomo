class EventsController < ApplicationController
  after_action :create_notifications, only: [:create], if: -> { @event.persisted? }

  def edit
    @event = Event.find(params[:id])
  end

  def create
    @trip_location = TripLocation.find(params[:trip_location_id])
    @event = Event.new(event_params)
    @event.trip_location = @trip_location
    @event.user_id = current_user.id
    if @event.save
      redirect_to trip_trip_location_path(@trip_location.trip, @trip_location), notice: "The event was created"
    else
      redirect_to trip_trip_location_path(@trip_location.trip, @trip_location), notice: "There was an error creating the event"
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.assign_attributes(event_params)

    if @event.save
      redirect_to trip_trip_location_path(@event.trip_location.trip, @event.trip_location), notice: "The event was updated"
    else
      redirect_to trip_trip_location_path(@event.trip_location.trip, @event.trip_location), notice: "There was an error updating the event"
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to trip_trip_location_path(@event.trip_location.trip, @event.trip_location), notice: "The event was deleted"
  end

  private

  def event_params
    params.require(:event).permit(:name,
                                  :start_at,
                                  :start_at_time,
                                  :end_at,
                                  :end_at_time,
                                  :description,
                                  :location_id)
  end

  def create_notifications
    message = " created a new event on "
    trip_link = "<a href=#{trip_path(@trip_location.trip)}>#{@trip_location.trip.name}</a>"
    heading = "#{current_user.name} #{message} #{trip_link}"
    mobile_url = @trip_location.custom_email_html(@event, message, "new_event")
    push_message = "#{current_user.name} #{message} #{@trip_location.trip.name}"

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
