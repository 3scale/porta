@backend @ignore-backend
Feature: API Docs Account Data
  In order to make it easier for buyers to use API Docs
  I want to provide access to useful account data

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And an application plan "Default" of provider "foo.example.com"
    And a buyer "alice" signed up to provider "foo.example.com"
    And buyer "alice" has application "CuteWidget"

  Scenario: JSON description of useful account data for buyer
    When I log in as "alice" on foo.example.com
    Then "alice" should have access to useful account data

    Scenario: JSON description of useful account data for provider
      When current domain is the admin domain of provider "foo.example.com"
      When I log in as provider "foo.example.com"
      Then provider "foo.example.com" should have access to useful account data

  Scenario: Correct response when user not logged in
    Given the current domain is foo.example.com
    And I am not logged in
    Then I should not have access to useful account data
