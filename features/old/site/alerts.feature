Feature: Site settings
  In order to have under control notifications about my service limit alerts and violations
  As a provider
  I want to have alerts and violations notification settings

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"

  Scenario: Navigating to the settings area
    When I log in as provider "foo.example.com"
    When I follow "API" in the main menu
    Then I should see "alerts"

  @ignore-backend-alerts
  Scenario: Settings page

    When I log in as provider "foo.example.com"
     And I go to the alerts settings page
    And I should see alert settings:
      | Show Web Alerts to Admins of this Account             | 50 | 80 | 90 | 100 | 120 | 150 | 200 | 300 |
      | Send Email Alerts to Admins of this Account           | 50 | 80 | 90 | 100 | 120 | 150 | 200 | 300 |
      | Show Web Alerts to Admins of the Developer Account    | 50 | 80 | 90 | 100 | 120 | 150 | 200 | 300 |
      | Send Email Alerts to Admins of the Developer Account  | 50 | 80 | 90 | 100 | 120 | 150 | 200 | 300 |
    And I should see all alerts off

    When I check alert "100" in "Send Email Alerts to Admins of this Account" row
     And press "Update Alert Settings"
     And I go to the alerts settings page
    Then I should see checked alert "100" in "Send Email Alerts to Admins of this Account" row within notification settings
    When I uncheck alert "100" in "Send Email Alerts to Admins of this Account" row within notification settings
      And press "Update Alert Settings"
    Then I should see all alerts off

  @security @wip
  Scenario: Settings are not available for buyers
    Given provider "foo.example.com" has multiple applications enabled
      And a buyer "bob" signed up to provider "foo.example.com"
    When I log in as "bob" on foo.example.com
    When I request the url of the 'alerts settings' page then I should see an exception
