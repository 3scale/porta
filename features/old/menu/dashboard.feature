@javascript
Feature: Dashboard
  In order to navigate easily
  As a provider
  I want to have important links on the dashboard

  Background:
    Given a provider is logged in
    And All Dashboard widgets are loaded

  Scenario: Audience widget
    And I go to the provider dashboard
    Then I should see "AUDIENCE" in the audience dashboard widget
    And I should see the link "0 ACCOUNTS" in the audience dashboard widget
    And I should see the link "PORTAL" in the audience dashboard widget
    And I should see the link "0 DRAFTS" in the audience dashboard widget
    And I should see the link "0 MESSAGES" in the audience dashboard widget

  Scenario: Audience widget with Finance enabled
    Given the provider is charging its buyers
    And I go to the provider dashboard
    Then I should see the link "BILLING" in the audience dashboard widget
