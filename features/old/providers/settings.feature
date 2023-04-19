Feature: Settings management
  In order to control the settings
  As a provider
  I want to be able to manage the settings

  Background:
    Given a provider is logged in

  @javascript
  Scenario: Strong password setting
    And I go to the usage rules settings page
    When I check "Strong passwords"
    And I press "Update Settings"
    Then I should see the settings updated
    And provider "foo.3scale.localhost" should have strong passwords enabled
    When I uncheck "Strong passwords"
    And I press "Update Settings"
    Then I should see the settings updated
    And provider "foo.3scale.localhost" should have strong passwords disabled
