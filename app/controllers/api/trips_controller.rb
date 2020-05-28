class Api::TripsController < Api::BaseController
  def trip_list
    @data = []
    friends_of_friends_ids = current_user.friends.map { |frnd| frnd.friends.map(&:id) }.flatten.compact.uniq
    friend_ids = current_user.friends.map(&:id) 
    if params[:search_by] == "Public"
      filter_trips = TripLocation.joins(:trip).where("trips.privacy_settings = ? OR trips.user_id = ?", params[:search_by], current_user.id).order("created_at desc")
    elsif params[:search_by] == "MyNetwork"
      filter_trips = TripLocation.joins(:trip).where("(trips.privacy_settings IN (?) AND trips.user_id IN (?)) OR (trips.user_id = ?)", ["MyNetwork", "Public"], friend_ids, current_user.id).order("created_at desc")
    elsif params[:search_by] == "FriendsOfFriends"
      filter_trips = TripLocation.joins(:trip).where("(trips.privacy_settings IN (?) AND trips.user_id IN (?)) OR (trips.user_id = ?)", ["FriendsOfFriends", "Public"], friends_of_friends_ids, current_user.id).order("created_at desc") 
    end
    # filter_trips = TripLocation.joins(:trip).where("trips.privacy_settings = ? OR (trips.privacy_settings = ? AND trips.user_id = ?) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR trips.user_id = ?", "Public", "JustMe", current_user.id, "MyNetwork", friend_ids, "FriendsOfFriends", (friends_of_friends_ids + friend_ids).uniq, current_user.id).order("updated_at DESC")
    if params[:search].present? 
      search_params = params[:search].split.map(&:capitalize).join(" ")
      user_ids = User.where("name LIKE ?", "%#{search_params}%").map(&:id)
      city_ids = Location.where("name LIKE ?", "%#{search_params}%").map(&:id) 
      filter_trips = filter_trips.where("trip_locations.location_id in (?) OR trips.user_id in (?)", city_ids, user_ids)
    end  
    filter_trips.each do |trip_location_obj|
      path = "https://maps.googleapis.com/maps/api/staticmap?markers=icon:https://s3-us-west-1.amazonaws.com/nomofomo-ios/location.png|#{trip_location_obj.location.lat.to_f},#{trip_location_obj.location.lng.to_f}&zoom=7&size=400x400&key=AIzaSyBxRK4asHJy4AsjdpAWUlahA8QD8uMyFUU"
      trip_object = trip_location_obj.trip
      city_with_state = trip_location_obj.location.formatted_address.split(", ")
      city_with_state = "#{city_with_state[0]}, #{city_with_state[1]}"
      trip_location = { id: trip_location_obj.id, city: city_with_state, latitute: trip_location_obj.location.lat.to_f, longitute: trip_location_obj.location.lng.to_f, start_at: trip_location_obj.start_at.strftime("%b %d, %Y"), end_at: trip_location_obj.end_at.strftime("%b %d, %Y"), google_place_id: trip_location_obj.location.google_place_id, location_path: path, participants: trip_location_obj.participants.count }
      trip = { trip_id: trip_object.id, name: trip_object.name, created_at: trip_object.created_at, trip_type: trip_object.privacy_settings }
      user = { id: trip_object.user.id, name: trip_object.user.name, picture: trip_object.user.picture, fb_image: trip_object.user.fb_image }
      user_is_like = trip_location_obj.activity.likes.map(&:user_id).include?(current_user.id) ? true : false
      like = trip_location_obj.activity.likes.count
      trip_and_location = trip.merge(location: trip_location, user: user, comment: trip_location_obj.activity.comments.count, like: like, is_like: user_is_like)
      @data.push(trip_and_location)
    end
    @message = @data.blank? ? "No trip found" : "List of trips"
    response_params_with_data
  end

  def trip_comments
    @data = []
    TripLocation.find_by_id(params[:trip_location_id]).activity.comments.order("created_at ASC").each do |comment| 
      user = comment.user
      @data.push(id: comment.id, user_name: user.name, user_id: user.id, picture: user.picture, fb_image: user.fb_image, body: comment.body.delete("\t\r\n").strip, comment_date: comment.created_at)
    end
    @message = @data.blank? ? "No comment found" : "List of comments"
    response_params_with_data
  end

  def trip_detail
    @data = []
    trip_location = TripLocation.find_by_id(params[:trip_location_id])
    attachments = trip_location.images.select(:id, :trip_location_id, :image_path, :user_id)
    path = "https://maps.googleapis.com/maps/api/staticmap?markers=icon:https://s3-us-west-1.amazonaws.com/nomofomo-ios/location.png|#{trip_location.location.lat.to_f},#{trip_location.location.lng.to_f}&zoom=7&size=400x400&key=AIzaSyBxRK4asHJy4AsjdpAWUlahA8QD8uMyFUU"
    participants = trip_location.participants.select(:id, :name, :picture, :fb_image)
    request = (participants.map(&:id) + trip_location.requests_to_join.map(&:user_id)).include?(current_user.id) ? true : false
    accommodations = trip_location.accommodations.select(:id, :name, :arriving_at, :departing_at, :location_id, :reservation_number, :description, :user_id, :arriving_at_time, :departing_at_time)
    accommodation_json_format = []
    accommodations.each do |object| 
      @accommodation, user = accomm_event_travel_user(object.user, object)
      accommodation_json_format.push(@accommodation.merge(user: user))
    end
    travels = trip_location.travels.select(:id, :name, :departure_location_id, :departing_at, :departing_at_time, :arrival_location_id, :arriving_at, :arriving_at_time, :reservation_number, :airline, :flight_number, :description, :user_id)
    travels_json_format = []
    travels.each do |object| 
      @travel, user = accomm_event_travel_user(object.user, object)
      @travel["departure_location_id"] = object.departure_location_id.nil? ? " " : object.departure_location.google_place_id
      @travel["arrival_location_id"] = object.arrival_location_id.nil? ? " " : object.arrival_location.google_place_id
      @travel["departure_city"] = object.departure_location_id.nil? ? " " : object.departure_location.formatted_address
      @travel["arrival_city"] = object.arrival_location_id.nil? ? " " : object.arrival_location.formatted_address
      travels_json_format.push(@travel.merge(user: user))
    end
    events = trip_location.events.select(:id, :name, :start_at, :end_at, :user_id, :location_id, :start_at_time, :end_at_time, :description)
    events_json_format = []
    events.each do |object| 
      @events, user = accomm_event_travel_user(object.user, object)
      events_json_format.push(@events.merge(user: user))
    end
    is_invite = trip_location.trip_location_invitations.map(&:recipient_user_id).include?(current_user.id) ? true : false
    @data.push(trip_location_id: trip_location.id, city: trip_location.location.name, trip_owner_id: trip_location.trip.user_id, trip_id: trip_location.trip.id, google_place_id: trip_location.location.google_place_id, trip_type: trip_location.trip.privacy_settings, name: trip_location.trip.name, start_at: trip_location.start_at.strftime("%b %d, %Y"), end_at: trip_location.end_at.strftime("%b %d, %Y"), location_path: path, request_sent: request, is_invite: is_invite, participants: participants, accommodations: accommodation_json_format, tavles: travels_json_format, events: events_json_format, trip_images: attachments)
    @message = "Detail of trip"
    response_params_with_data
  end

  def create
    @location, @message = Location.user_location_for_api(params[:google_place_id])
    trip_params = trip_and_trip_location
    @trip = Trip.create(trip_params)
    if @trip.id.present?
      @trip.create_notifications
      analytic = Analytic.create_analytic(current_user.id, params[:device_type], nil, "trip_created", params[:vs], params[:app_version], nil, nil)
      analytic.update_attributes(metric_classification: @trip.privacy_settings, metric_identifier: @trip.id)
      send_invitation unless params[:user_ids].blank?
      @message = "Trip successfully created."
      @data = { trip_id: @trip.id, trip_location_id: @trip.trip_locations.first.id }
      response_params_with_data
    else
      @message = "Trip not successfully created."
      failed_response_params
    end
  end 

  def destroy
    @trip = Trip.find(params[:trip_id])&.destroy
    @message = "Trip successfully destroyed."
    success_response_params
  end

  def update
    @trip = Trip.find(params[:trip_id])
    @location, @message = Location.user_location_for_api(params[:google_place_id])
    trip_location = @trip.trip_locations.first
    if trip_location.update_attributes(location_id: @location.id, start_at: params[:start_at], end_at: params[:end_at]) && @trip.update_attributes(privacy_settings: params[:privacy_settings]) 
      send_invitation unless params[:user_ids].blank?
      @message = "Trip successfully updated."
      success_response_params
    else
      @message = "Trip not successfully updated."
      failed_response_params
    end
  end

  def send_invitation
    sender = current_user
    User.where("id in (?)", params[:user_ids]).uniq.each do |user|
      invitation = TripLocationInvitation.new(trip_location_id: @trip.trip_locations[0].id, sender_user_id: sender.id, recipient_user_id: user.id)
      if invitation.save
        message = " invited you to the city "
        heading = "<a href=#{user_path(sender)}>#{sender.name}</a>#{message}<a href=#{trip_trip_location_path(@trip, @trip)}>#{@location.name}</a>"
        mobile_url = @trip.trip_locations[0].custom_email_html(@trip, message, "invite_trip")
        Notification.create(heading: heading, recipient_user_id: user.id, sender_user_id: sender.id, notify_type: "invite_trip", trip_location_id: @trip.trip_locations[0].id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_TRIP_INVITATIONS, context: mobile_url)
        push_message = "#{sender.name}#{message}#{@location.name}"
        if user.ios_device_token.present?  
          device_token = user.ios_device_token
          type = "ios"
        else
          device_token = user.android_device_token
          type = "android"
        end
        data = { notify_type: "invite_trip", sender_user_id: sender.id, recipient_user_id: user.id, trip_location_id: @trip.trip_locations[0], trip_id: @trip.id, name: sender.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
    end
  end

  def trip_and_trip_location
    { name: "My Nomo-Fomo", privacy_settings: params[:privacy_settings], user_id: current_user.id }.merge(trip_locations_attributes: { "0" => { "location_id" => @location.id, "start_at" => params[:start_at], "end_at" => params[:end_at] } })
  end

  private

  def accomm_event_travel_user(user_object, object)
    json_object = object.as_json
    json_object.delete("user_id")

    if json_object["start_at"].present?
      json_object["start_at"] = object.start_at.strftime("%b %d, %Y")
      json_object["end_at"] = object.end_at.strftime("%b %d, %Y")
    else
      json_object["departing_at"] = object.departing_at.strftime("%b %d, %Y")
      json_object["arriving_at"] = object.arriving_at.strftime("%b %d, %Y")
    end

    if json_object.include?("location_id")
      json_object["location_id"] = object.location_id.nil? ? " " : object.location.google_place_id
      json_object["address"] = object.location_id.nil? ? " " : object.location.formatted_address
    end

    user = user_object.nil? ? { id: 0, name: "NomoFomo", picture: " ", fb_image: " " } : User.select(:id, :name, :picture, :fb_image).find_by_id(user_object.id).as_json
    [json_object, user]
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

  def response_params_with_data
    render json: {
      success: true,
      message: @message,
      data: @data
    }
  end

  def trip_params
    params.require(:trip).permit(:user_id,
                                 :description,
                                 :name,
                                 :privacy_settings,
                                 trip_locations_attributes: %i(id location_id start_at end_at _destroy))
  end
end

