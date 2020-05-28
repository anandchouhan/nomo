# require "rails_helper"
#
# RSpec.feature "Login", js: true do
#   let(:user) { FactoryBot.create(:user) }
#   let!(:waitlist) { FactoryBot.create(:waitlist) }
#   let!(:waitlist2) { FactoryBot.create(:waitlist, email: user.email, position: 0) }
#
#   scenario "User can sign in" do
#     visit root_path
#
#     within ".hero" do
#       click_on "Sign In"
#     end
#
#     within "#loginModal" do
#       fill_in "Email Address", with: user.email
#       fill_in "Password", with: "Pass$123"
#       click_on "Sign In"
#     end
#
#     expect(page.html).to have_content "Signed in successfully."
#   end
#
#   scenario "User can't sign in without existing" do
#     visit root_path
#
#     within ".hero" do
#       click_on "Sign In"
#     end
#
#     within "#loginModal" do
#       fill_in "Email Address", with: "test@test.com"
#       fill_in "Password", with: "Pass$123"
#       click_on "Sign In"
#
#       expect(page.html).to have_content "We're sorry, you have not been invited yet. See your current position by clicking on \"join the waitlist\" below and checking your place in line. Remember to share us via your specialized URL to move up spots!"
#     end
#   end
#
#   scenario "User can reset password" do
#     visit root_path
#
#     within ".hero" do
#       click_on "Sign In"
#     end
#
#     within "#loginModal" do
#       click_on "Forgot Password?"
#     end
#
#     expect(page.current_path).to eq new_user_password_path
#
#     fill_in "Email Address", with: user.email
#     click_on "Send me reset password instructions"
#
#     expect(page.html).to have_content "You will receive an email with instructions on how to reset your password in a few minutes."
#   end
#
#   scenario "User can't reset password if not a user" do
#     visit root_path
#
#     within ".hero" do
#       click_on "Sign In"
#     end
#
#     within "#loginModal" do
#       click_on "Forgot Password?"
#     end
#
#     expect(page.current_path).to eq new_user_password_path
#
#     fill_in "Email Address", with: "test@test.com"
#     click_on "Send me reset password instructions"
#
#     expect(page.html).to have_content "Email not found"
#   end
# end
