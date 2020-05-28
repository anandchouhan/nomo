class TripsService
  def update(params = {})
    raise "Trip Not Present" if @trip.new_record?
    if @trip.update(sanatized_trip_params(params))
      return { success: true, trip: @trip, msg: "Trip Updated successfully" }
    else
      return { success: false, error_msg: @trip.errors.full_messages.join(", ") }
    end
  end

  def create(params = {})
    raise "Trip Exists" unless @trip.new_record?
    @trip.attributes = sanatized_trip_params(params)
    if @trip.save
      return { success: true, trip: @trip, msg: "Trip Created successfully" }
    else
      return { success: false, error_msg: @trip.errors.full_messages.join(", ") }
    end
  end

  private

  def sanatized_trip_params(params)
    if params[:location_id].blank? && params[:facebook_oid].present?
      set_fb_location(params[:facebook_oid])
      params[:location_id] = @location.try(:id)
    end
    params.permit(:location_id, :start_at, :end_at, :type, :user_id, :name)
  end

  def set_fb_location(fb_oid)
    @location = Location.find_by(facebook_oid: fb_oid)
  end
end
