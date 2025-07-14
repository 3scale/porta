@javascript
Feature: Provider login page

  Background:
    Given a provider

  Scenario: Provider lands in dashboard when login in master domain
    When the provider logs in
    Then the current page is the provider dashboard

  Scenario: Provider lands in admin dashboard when he requests public login page
    Given the provider logs in
    When they go to the provider login page
    Then the current page is the provider dashboard

  @security
  Scenario: Buyer cannot login in admin domain
    Given a buyer "buyer"
    When they try to log in as provider "buyer"
    Then they should see "Incorrect email or password. Please try again"
    And should not be logged in
