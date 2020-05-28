Given ("a user is on the splash page") do
  visit("/")
  expect(page).to have_content("The Perfect Combination of")
end

Given ("a user with a waitlist set up through {string} with a position of {string} exists") do |arg1, arg2|
  Waitlist.create!(
    name: "Cucumber Bob",
    email: "cucumber_bob@tfbnw.net",
    position: arg2
  )
  Waitlist.last.name == "Cucumber Bob"
  if arg1 == "Facebook"
    Waitlist.last.update_attributes!(uid: "12345678910")
  end
end

Given ("a user with an account set up through {string} exists") do |arg|
  User.create!(
    name: "Cucumber Bob",
    email: "cucumber_bob@tfbnw.net",
    username: "cucumbob",
    date_of_birth: "Mon, 01 Jan 1990",
    password: "password"
  )
  User.last.name == "Cucumber Bob"
  if arg == "Facebook"
    User.last.update_attributes!(
      provider: "facebook",
      uid: "12345678910"
    )
  end
end

When ("they click on sign in") do
  find(".hero-signin").click
end

When ("they submit their waitlist email") do
  within(:css, "#waitlistPositionModal") do
    fill_in "search", with: "cucumber_bob@tfbnw.net"
    click_button "Check position"
  end
end

When ("they submit email account information") do
  fill_in "user_email", with: "cucumber_bob@tfbnw.net"
  fill_in "user_password", with: "password"
  click_button "Sign In"
end

When ("they click on sign in with facebook") do
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = {
    provider: "facebook",
    uid: "12345678910",
    info: {
      email: "cucumber_bob@tfbnw.net",
      first_name: "Cucumber",
      last_name: "Bob",
      image: nil
    },
    credentials: {
      token: "23ihtngoi3j0219u98ut1",
      expires_at: Time.now + 10.minutes
    },
    extra: {
      raw_info: {
        age_range: {
          min: 18
        }
      }
    }
  }
  first(".sign-in-facebook").click
end

Then ("they should not be logged in") do
  expect(page).to have_content("We're sorry, you have not been invited yet.")
end

Then ("they should be logged in") do
  expect(page).to have_content("Signed in successfully.")
end

Then ("they should see their waitlist position") do
  expect(page).to have_content("Congrats, you have moved up the waitlist! Sign up anytime here")
end

Then ("there should be one waitlist") do
  expect(Waitlist.count).to eq(1)
end

Then ("there should be one user") do
  expect(User.count).to eq(1)
end

Then ("there should be no waitlist") do
  expect(Waitlist.count).to eq(0)
end

Then ("there should be no user") do
  expect(User.count).to eq(0)
end
