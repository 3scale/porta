Feature: Dashboard
  In order to navigate easily
  As a provider
  I want to have important links on the dashboard

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And All Dashboard widgets are loaded

  Scenario: Audience widget
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider dashboard
    Then I should see "Audience" in the audience dashboard widget
    And I should see the link "0 Accounts" in the audience dashboard widget
    And I should see the link "Portal" in the audience dashboard widget
    And I should see the link "0 Drafts" in the audience dashboard widget
    And I should see the link "0 Messages" in the audience dashboard widget

  @javascript
  Scenario: first API widget
    When I log in as provider "foo.3scale.localhost"
    And I should see "API" in the first api dashboard widget

  Scenario: Audience widget with Finance enabled
    Given provider "foo.3scale.localhost" is charging
    And provider "foo.3scale.localhost" has "finance" switch allowed
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider dashboard
    Then I should see the link "Billing" in the audience dashboard widget
