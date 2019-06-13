Feature: Applications management
  In order to control the way my buyers are using my API
  As a provider
  I want manage their applications

  Background:
    Given a provider is logged in
      And has an application
      And there are no events

  Scenario: Delete application
    When I'm on that application page
     And I follow "Edit"
     When I follow "Delete" and I confirm dialog box
    Then I should see "The application was successfully deleted."
     And there should be 1 application cancelled event
     And all the events should be valid
