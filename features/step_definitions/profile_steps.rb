Given("a user has previously registered") do
  Waitlist.create!(email: "test@email.com", position: 0)

  @test_user = User.create!(
    email: "test@email.com",
    name: "Mr Test",
    password: "password",
    date_of_birth: Date.parse("16/02/1988"),
    viewed_walkthrough: 2
  )
end

Given("they are logged in") do
  visit new_user_session_path
  fill_in "user_email", with: @test_user.email
  fill_in "user_password", with: "password"
  click_button "Sign In"
end

Given("they have a complete profile") do
  @test_user.update!(
    bio: "This is my bio, aren't I amazing?"
  )

  @fact1 = Fact.create!(
    description: "This is a cool fact",
    user_id: @test_user.id
  )

  @fact2 = Fact.create!(
    description: "This is also a cool fact",
    user_id: @test_user.id
  )
end

Given("they have posted something") do
  @post1 = Post.create!(
    body: "Look at my amazing post, I'm the best.",
    user_id: @test_user.id
  )
end

Given("they have a friend who has posted something") do
  @test_users_friend1 = User.create!(
    email: "testfriend@email.com",
    name: "Mr Test's Friend",
    password: "password",
    date_of_birth: Date.parse("11/03/1988")
  )

  @friends_post1 = Post.create!(
    body: "Look at my amazing post, I'm the second best after Mr Test.",
    user_id: @test_users_friend1.id
  )
end

When("they visit their profile page") do
  visit profile_path(@test_user.profile)
end

Then("they should see their short bio") do
  expect(page).to have_content("This is my bio, aren't I amazing?")
end

Then("they should see their facts") do
  expect(page).to have_content("This is a cool fact")
  expect(page).to have_content("This is also a cool fact")
end

Then("they should see their post") do
  # Need the Public Activity intro to know how to test this
  # expect(page).to have_content("Look at my amazing post, I'm the best.")
end

Then("they should see their friend's post") do
  # Need the Public Activity intro to know how to test this
  # expect(page).to have_content("Look at my amazing post, I'm the second best after Mr Test.")
end
