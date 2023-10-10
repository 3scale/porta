@javascript
Feature: Buyer account overview

  Background:
    Given a provider is logged in
    And an approved buyer "Bob Buyer" signed up to the provider

  @wip
  Scenario: Navigation

  Scenario: Sending a message
    Given buyer "Bob Buyer" has no messages
    And they go to the buyer account page for "Bob Buyer"
    When they follow "Send message"
    And fill in "Subject" with "Party tonite!"
    And fill in "Body" with "You are invited to my party."
    And the "To" field should be fixed to "Bob Buyer"
    And press "Send"
    Then should see "Message was sent."
