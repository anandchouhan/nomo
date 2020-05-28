Given("there is a location") do
  @location1 = Location.create!(name: "Santosville")
end

Given("they have created a trip") do
  @trip = @test_user.trips.create!(
    location_id: @location1.id,
    start_at: Date.new,
    end_at: Date.new + 3
  )

  @trip.save
end

When("they visit their trip page") do
  visit trip_path(@trip)
end

When("fill in the create event form") do
  fill_in "event_name", with: "Birthday Party"
  page.execute_script("document.getElementById('event_location_id').value = '" + @location1.id.to_s + "'")
  fill_in "event_start_at", with: "2022/03/16 13:00"
  fill_in "event_end_at", with: "2022/03/16 18:00"
  fill_in "event_description", with: "Please come to my birthday, I have no friends."
  click_button "Add Event"
end

Then("an event should be created") do
  expect(Event.last.name).to eq("Birthday Party")
end

Then("they should see it on the page") do
  expect(page).to have_content("Birthday Party")
end
