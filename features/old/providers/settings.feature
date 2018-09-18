Feature: Settings management
  In order to control the settings
  As a provider
  I want to be able to manage the settings

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"

  @javascript
  Scenario: Strong password setting
    When I log in as provider "foo.example.com"
      And I go to the usage rules settings page

    When I check "Strong passwords"
     And I press "Update Settings"
    Then I should see the settings updated
     And provider "foo.example.com" should have strong passwords enabled

    When I uncheck "Strong passwords"
     And I press "Update Settings"
    Then I should see the settings updated
     And provider "foo.example.com" should have strong passwords disabled
