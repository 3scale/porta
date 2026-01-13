@javascript
Feature: Admin portal dashboard

  Background:
    Given a provider
    And a product "Bananas"
    And the provider logs in

  Scenario: No accounts have signed up yet
    Given the provider does not have signups
    When they go to the provider dashboard
    Then they should not see the new accounts chart
    But they should see "Make it easy for developers to sign up using your Developer Portal"

  Scenario: Account signups are displayed in a chart
    Given the provider has signups
    When they go to the provider dashboard
    Then they should see the new accounts chart

  Scenario: Admins are redirected to provider dashboard
    When they go to the dashboard
    Then they should be on the provider dashboard

  Scenario: Buyers are redirected to the dev portal
    Given a buyer "Jane"
    When the buyer logs in
    And they go to the provider dashboard
    Then they should be on the dashboard
