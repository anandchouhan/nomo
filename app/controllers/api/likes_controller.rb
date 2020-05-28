class Api::LikesController < Api::BaseController
  def create
    @trip_location = TripLocation.find(params[:trip_location_id])
    @activity = @trip_location.activity
    @like = @activity.likes.create(user_id: current_user.id)
    create_notifications unless current_user.id == @trip_location.trip.user_id
    render json: {
      success: true,
      message: "You liked on the trip location"
    }
  end

  def destroy
    trip_location = TripLocation.find(params[:trip_location_id])
    activity = trip_location.activity
    like = Like.where(likeable_type: "Activity", likeable_id: activity.id, user_id: current_user.id)
    if like.present?
      like.destroy_all
      Notification.where("sender_user_id = ? AND recipient_user_id = ? AND notify_type = ?", current_user.id, trip_location.trip.user, "like").destroy_all
      render json: {
        success: true,
        message: "You unliked on the trip location"
      }
    end
  end

  private

  def create_notifications
    message = " liked that you are traveling to "
    user_link = "<a href=#{user_path(current_user)}>#{current_user.name}</a>"
    heading = "#{user_link}#{message}<a href=#{trip_trip_location_path(@trip_location.trip, @trip_location)}>#{@trip_location.location.name}</a>"
    mobile_url = @trip_location.custom_email_html(@like, message, "like")
    push_message = "#{current_user.name}#{message}#{@trip_location.location.name}"
    Analytic.create_analytic(current_user.id, params[:device_type], nil, "trip_location_liked", params[:vs], params[:app_version], nil, nil)
    Notification.create(heading: heading, recipient: @trip_location.trip.user, sender: current_user, notify_type: "like", trip_location_id: @trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_LIKES_IN_MY_ACTIVITY, context: mobile_url)
    if @trip_location.trip.user.ios_device_token.present?  
      device_token = @trip_location.trip.user.ios_device_token
      type = "ios"
    else
      device_token = @trip_location.trip.user.android_device_token
      type = "android"
    end
    data = { notify_type: "like", sender_user_id: current_user.id, recipient_user_id: @trip_location.trip.user.id, trip_location_id: @trip_location.id, trip_id: @trip_location.trip.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
    Notification.send_push_notification(data) if device_token.present?
  end
end
