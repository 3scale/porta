@javascript
Feature: Settings management
  In order to control the settings
  As a provider
  I want to be able to manage the settings

  Background:
    Given a provider is logged in

  Scenario: Strong password setting
    And I go to the usage rules settings page
    When I check "Strong passwords"
    And I press "Update Settings"
    Then they should see a toast alert with text "Settings updated"
    And the provider should have strong passwords enabled
    When I uncheck "Strong passwords"
    And I press "Update Settings"
    Then they should see a toast alert with text "Settings updated"
    And the provider should have strong passwords disabled

  Scenario: Account approval required checkbox is enabled
    Given the provider has 1 account plan
    When I go to the usage rules settings page
    Then field "Account approval required" is not disabled

  Scenario: Account approval required checkbox is disabled
    Given the provider has multiple account plans
    And the provider has "Account plans UI visible" set to "true"
    When I go to the usage rules settings page
    Then field "Account approval required" is disabled

  Scenario: Account approval required checkbox is not visible
    Given the provider has multiple account plans
    And the provider has "Account plans UI visible" set to "false"
    When I go to the usage rules settings page
    Then I should not see "Account approval required"
