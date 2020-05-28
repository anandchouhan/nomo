# require "rails_helper"
#
# RSpec.feature "Splash Page", js: true do
#   let!(:waitlist) { FactoryBot.create(:waitlist) }
#
#   context "As a waitlisted user" do
#     let(:user) { FactoryBot.create(:user) }
#
#     before(:each) do
#       include_steps :waitlist, user
#     end
#
#     scenario "User can sign up for the waitlist" do
#       expect(page).to have_content "You are number 11 out of 11 on the waitlist to get access."
#     end
#
#     scenario "User can check their position in the waitlist" do
#       visit root_path
#
#       within ".hero" do
#         click_on "Request an Invite"
#       end
#
#       click_on "I am already on the waitlist, I want to check my place."
#
#       within "#waitlistPositionModal" do
#         fill_in "search", with: user.email
#         click_on "Check position"
#
#         expect(page).to have_content "You are number 11 out of 11 on the waitlist to get access."
#       end
#     end
#   end
#
#   scenario "User gets error modal when not on waitlist" do
#     visit root_path
#
#     within ".hero" do
#       click_on "Request an Invite"
#     end
#
#     click_on "I am already on the waitlist, I want to check my place."
#
#     within "#waitlistPositionModal" do
#       fill_in "search", with: Faker::Internet.email
#       click_on "Check position"
#     end
#
#     expect(page).to have_content "Looks like you haven't joined the waitlist yet"
#   end
# end
