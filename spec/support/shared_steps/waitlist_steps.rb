shared_steps :waitlist do |user|
  visit root_path

  within ".hero" do
    click_on "Request an Invite"
  end

  fill_in "waitlist_name", with: user.name
  fill_in "waitlist_email", with: user.email
  click_on "Submit"
end
