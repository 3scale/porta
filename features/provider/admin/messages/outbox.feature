Feature: Outbox messages
  In order to facilitate communication between me and my buyers
  As a provider
  I want to have an internal messaging system at my disposal

  Background:
    Given a provider "foo.3scale.localhost"
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    Given these buyers signed up to provider "foo.3scale.localhost"
      | jane | foo.3scale.localhost | JaneApp, JaneAppTwo |
    Given I am logged in as provider "foo.3scale.localhost"
      And I am on the outbox compose page

  Scenario: Outbox Message can't be sent without subject
    And I fill in "Body" with "Subject is empty"
    And I press "Send"
    Then I should see "Compose"
    And I am on the outbox compose page

  Scenario: Outbox Message can't be sent without body
    And I fill in "Subject" with "Body is empty"
    And I press "Send"
    Then I should see "Compose"
    And I am on the outbox compose page
