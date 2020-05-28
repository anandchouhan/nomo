# Trip location channel that will be manage connections to a single trip location.
# Every time a trip location field changes, this new field will be sent through a WebSocket.
class TripLocationChannel < ApplicationCable::Channel
  def subscribed
    trip_location = TripLocation.find(params[:id])
    stream_for trip_location
  end
end