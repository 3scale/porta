@javascript
Feature: Rejecting buyer account
  In order to let know my new buyers that I don't like them
  As a provider
  I want to reject them

  Background:
    Given a provider is logged in
    And the provider has multiple applications enabled
    And the provider requires cinstances to be approved before use
    And the provider requires accounts to be approved

  Scenario: Rejecting a single buyer account
    Given a pending buyer "bob" signed up to provider "foo.3scale.localhost"
    When I go to the buyer account page for "bob"
    And I press "Reject"
    Then buyer "bob" should be rejected

  Scenario: Reject button is not shown for already rejected accounts
    Given a rejected buyer "bob" signed up to provider "foo.3scale.localhost"
    When I go to the buyer account page for "bob"
    Then I should not see button to reject buyer "bob"

  Scenario: Reject button is not shown for approved accounts
    Given an approved buyer "bob" signed up to provider "foo.3scale.localhost"
    When I go to the buyer account page for "bob"
    Then I should not see button to reject buyer "bob"
