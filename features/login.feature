Feature: Logins
  Background: 
    Given a user is on the splash page

  Scenario: A user without an account tries to log in with Facebook
    When they click on sign in
      And they click on sign in with facebook
    Then they should not be logged in
      And there should be no waitlist
      And there should be no user

  Scenario: A user with an account set up through Facebook logs in with Facebook
    Given a user with a waitlist set up through "Facebook" with a position of "0" exists
      And a user with an account set up through "Facebook" exists
    When they click on sign in
      And they click on sign in with facebook
    Then they should be logged in
      And there should be one waitlist
      And there should be one user

  Scenario: A user on the waitlist through Facebook tries to log in with Facebook
    Given a user with a waitlist set up through "Facebook" with a position of "2" exists
    When they click on sign in
      And they click on sign in with facebook
    Then they should not be logged in
      And there should be one waitlist
      And there should be one user

  Scenario: A user without an account tries to log in with Email
    When they click on sign in
      And they submit email account information
    Then they should not be logged in
      And there should be no waitlist
      And there should be no user

  Scenario: A user with an account set up through email logs in with email
    Given a user with a waitlist set up through "email" with a position of "0" exists
      And a user with an account set up through "email" exists
    When they click on sign in
      And they submit email account information
    Then they should be logged in
      And there should be one waitlist
      And there should be one user

  Scenario: A user with a waitlist through email tries to log in with email
    Given a user with a waitlist set up through "email" with a position of "2" exists
    When they click on sign in
      And they submit email account information
    Then they should not be logged in
      And there should be one waitlist
      And there should be no user

  Scenario: A user with a waitlist(position 2) through email tries to log in with Facebook
    Given a user with a waitlist set up through "email" with a position of "2" exists
    When they click on sign in
      And they click on sign in with facebook
    Then they should not be logged in
      And there should be one waitlist
      And there should be one user

  Scenario: A user with a waitlist(position 0) through email logs in with Facebook
    Given a user with a waitlist set up through "email" with a position of "0" exists
    When they click on sign in
      And they click on sign in with facebook
    Then they should be logged in
      And there should be one waitlist
      And there should be one user

  Scenario: A user with an account set up through email tries to log in with Facebook
    Given a user with a waitlist set up through "email" with a position of "0" exists
      And a user with an account set up through "email" exists
    When they click on sign in
      And they click on sign in with facebook
    Then they should be logged in
      And there should be one waitlist
      And there should be one user

  Scenario: A user with a waitlist set up through email checks their position with email
    Given a user with a waitlist set up through "email" with a position of "0" exists
    When click "I am already on the waitlist, I want to check my place."
      And they submit their waitlist email
    Then they should see their waitlist position
      And there should be one waitlist
      And there should be no user

  Scenario: A user with a waitlist set up through Facebook checks their position with email
    Given a user with a waitlist set up through "Facebook" with a position of "0" exists
    When click "I am already on the waitlist, I want to check my place."
      And they submit their waitlist email
    Then they should see their waitlist position
      And there should be one waitlist
      And there should be no user
