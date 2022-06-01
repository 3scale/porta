@javascript
Feature: Outbox messages
  In order to facilitate communication between me and my buyers
  As a provider
  I want to have an internal messaging system at my disposal

  Background:
    Given a provider is logged in

  Scenario: Outbox Message can't be sent without subject/body
    Given I am logged in as provider "foo.3scale.localhost"
    And I am on the outbox compose page
    And a clear email queue
    And I fill in "Body" with "There is no Subject to this email"
    And I press "Send"
    Then I should see "Compose"
    And "jane@me.us" should receive no emails
