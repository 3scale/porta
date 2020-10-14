Feature: Dashboard
  In order to navigate easily
  As a provider
  I want to have important links on the dashboard

  Background:
    Given a provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    And All Dashboard widgets are loaded

  Scenario: Audience widget
    When I log in as provider "foo.example.com"
    And I go to the provider dashboard
    Then I should see "Audience" in the audience dashboard widget
    And I should see the link "0 Accounts" in the audience dashboard widget
    And I should see the link "Portal" in the audience dashboard widget
    And I should see the link "0 Drafts" in the audience dashboard widget
    And I should see the link "0 Messages" in the audience dashboard widget

  @javascript
  Scenario: APIs widget
    When I log in as provider "foo.example.com"
    And I go to the provider dashboard
    Then I should see "APIs" in the apis dashboard widget
    And I should see "Products" in the apis dashboard products widget
    And I should see the link "Create Product" in the apis dashboard products widget
    And I should see "Backends" in the apis dashboard backends widget
    And I should see the link "Create Backend" in the apis dashboard backends widget

  @javascript
  Scenario: first API widget
    When I log in as provider "foo.example.com"
    And I should see "API" in the first api dashboard widget

  Scenario: first API widget without APIAP
    Given I have rolling updates "api_as_product" disabled
    When I log in as provider "foo.example.com"
    And I should see "API" in the first api dashboard widget
    And I should see the link "Overview" in the first api dashboard widget
    And I should see the link "Analytics" in the first api dashboard widget
    And I should see the link "Integrate this API" in the first api dashboard widget
    And I should see the link "0 ActiveDocs" in the first api dashboard widget

  Scenario: Audience widget with Finance enabled
    Given provider "foo.example.com" is charging
    And provider "foo.example.com" has "finance" switch allowed
    When I log in as provider "foo.example.com"
    And I go to the provider dashboard
    Then I should see the link "Billing" in the audience dashboard widget
