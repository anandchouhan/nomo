json.array! @trip_locations do |trip_location|
  json.id trip_location.id
  json.trip_id trip_location.trip_id
  json.name trip_location.location.formatted_address
  json.start trip_location.start_at
  json.end trip_location.end_at + 1.day
  json.color trip_location.color
  json.allDay true
end
