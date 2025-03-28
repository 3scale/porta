@javascript
Feature: Approving buyer account
  In order to allow my new buyers to use the site when they seem allright
  As a provider
  I want to approve them

  Background:
    Given a provider is logged in
    And the provider has "multiple_applications" visible
    And the provider requires cinstances to be approved before use
    And the provider requires accounts to be approved

  Scenario: Approving a single buyer account
    Given a pending buyer "bob"
    When I go to the buyer account page for "bob"
    And I press "Approve"
    Then buyer "bob" should be approved

  Scenario: Approve button is not shown for already approved accounts
    Given an approved buyer "bob"
    When I go to the buyer account page for "bob"
    Then I should not see button to approve buyer "bob"

  Scenario: Approve button is not shown for rejected accounts
    Given a rejected buyer "bob"
    When I go to the buyer account page for "bob"
    Then I should not see button to approve buyer "bob"
