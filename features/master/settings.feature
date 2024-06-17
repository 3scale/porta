@javascript
Feature: Settings management
  In order to control the settings
  As a master
  I want to be able to manage the settings

  Background:
    Given master admin is logged in

  Scenario: Settings page loads properly
    When they go to the usage rules settings page
    Then they should see "Usage Rules"

  Scenario: Hide services is visible
    When they go to the usage rules settings page
    Then they should see "Hide services"
