# require "rails_helper"
#
# RSpec.feature "Calendar", js: true do
#   let(:user) { FactoryBot.create(:user) }
#   let!(:waitlist) { FactoryBot.create(:waitlist) }
#   let!(:waitlist2) { FactoryBot.create(:waitlist, email: user.email, position: 0) }
#   let(:trip) { FactoryBot.create(:trip) }
#
#   before(:each) do
#     include_steps :login, user, "Pass$123"
#
#     visit trips_path
#   end
#
#   scenario "User can see the calendar" do
#     skip "Feature specs need Google API credentials."
#     expect(page).to have_css "#calendar"
#   end
#
#   scenario "User can add a trip" do
#     skip "Feature specs need Google API credentials."
#     click_on "Add A Trip"
#
#     expect(page).to have_css "#addTripModal.show"
#
#     within "#addTripModal" do
#       fill_in "trip_start_at", with: trip.start_at
#       fill_in "trip_end_at", with: trip.end_at
#       fill_in "trip_name", with: trip.name
#       fill_in "Location", with: trip.location
#
#       click_on "Add Trip"
#     end
#
#     within ".calendar-trip-list" do
#       expect(page).to have_content trip.name
#       expect(page).to have_content trip.start_at
#       expect(page).to have_content trip.end_at
#       expect(page).to have_content trip.location
#     end
#   end
# end
