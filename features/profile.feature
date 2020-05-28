Feature: Profiles
  Scenario: A user views their profile
    Given a user has previously registered
      And they are logged in
      And they have a complete profile
      And they have posted something
      # And they have a friend who has posted something
    When they visit their profile page
    Then they should see their short bio
      And they should see their facts
      And they should see their post
      # And they should see their friend's post