@javascript
Feature: Settings management
  In order to control the settings
  As a provider
  I want to be able to manage the settings

  Background:
    Given a provider is logged in

  Scenario: Account approval required checkbox is enabled
    Given the provider has 1 account plan
    When I go to the usage rules settings page
    Then field "Account approval required" is not disabled

  Scenario: Account approval required checkbox is disabled
    Given the provider has multiple account plans
    And the provider has the following setting:
      | Account plans UI visible | true |
    When I go to the usage rules settings page
    Then field "Account approval required" is disabled

  Scenario: Account approval required checkbox is not visible
    Given the provider has multiple account plans
    And the provider has the following setting:
      | Account plans UI visible | false |
    When I go to the usage rules settings page
    Then I should not see "Account approval required"
