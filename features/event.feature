Feature: Events
  @javascript
  Scenario: A user creates an event
    Given a user has previously registered
      And they are logged in
      And there is a location
      And they have created a trip
    When they visit their trip page
      And click "+ Add Event"
      And fill in the create event form
    Then an event should be created
      And they should see it on the page
