Feature: Approving buyer account
  In order to allow my new buyers to use the site when they seem allright
  As a provider
  I want to approve them

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And current domain is the admin domain of provider "foo.example.com"
    And I am logged in as provider "foo.example.com"
    And provider "foo.example.com" requires cinstances to be approved before use
    And provider "foo.example.com" requires accounts to be approved

  Scenario: Approving a single buyer account
    Given a pending buyer "bob" signed up to provider "foo.example.com"
    When I go to the buyer account page for "bob"
    And I press "Approve"
    Then buyer "bob" should be approved

  Scenario: Approve button is not shown for already approved accounts
    Given an approved buyer "bob" signed up to provider "foo.example.com"
    When I go to the buyer account page for "bob"
    Then I should not see button to approve buyer "bob"

  Scenario: Approve button is not shown for rejected accounts
    Given a rejected buyer "bob" signed up to provider "foo.example.com"
    When I go to the buyer account page for "bob"
    Then I should not see button to approve buyer "bob"
