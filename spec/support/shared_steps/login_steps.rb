shared_steps :login do |user, password|
  visit root_path

  within ".hero" do
    click_on "Sign In"
  end

  within "#loginModal" do
    fill_in "Email Address", with: user.email
    fill_in "Password", with: password
    click_on "Sign In"
  end

  expect(page.html).to have_content "Signed in successfully."
end
