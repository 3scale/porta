@javascript
Feature: Dashboard
  In order to navigate easily
  As a provider
  I want to have important links on the dashboard

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

  Scenario: Audience widget
    When I go to the provider dashboard
    Then I should see "Audience" in the audience dashboard widget
    And I should see the link "0 Accounts" in the audience dashboard widget
    And I should see the link "Portal" in the audience dashboard widget
    And I should see the link "0 Drafts" in the audience dashboard widget
    And I should see the link "0 Messages" in the audience dashboard widget

  Scenario: APIs widget
    When I go to the provider dashboard
    Then I should see "APIs" in the apis dashboard widget
    And I should see the link "0 ActiveDocs" in the apis dashboard widget
    And I should see the link "New API" in the apis dashboard widget

  Scenario: first API widget
    And I should see "API" in the first api dashboard widget
    And I should see the link "Overview" in the first api dashboard widget
    And I should see the link "Analytics" in the first api dashboard widget
    And I should see the link "Integrate this API" in the first api dashboard widget
    And I should see the link "0 ActiveDocs" in the first api dashboard widget

  Scenario: Audience widget with Finance enabled
    Given provider "foo.example.com" is charging
    And provider "foo.example.com" has "finance" switch allowed
    When I go to the provider dashboard
    Then I should see the link "Billing" in the audience dashboard widget

  Scenario: API Widget with Service plans enabled and more than 1 service plan
    Given a service "Another one" of provider "foo.example.com"
    And provider "foo.example.com" has "service_plans" switch allowed
    And a service plan "second" of provider "foo.example.com"
    When I go to the provider dashboard
    Then I should see the link "0 Subscriptions" in the first api dashboard widget
