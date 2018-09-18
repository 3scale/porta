@ignore-backend
Feature: Metric visibility
  In order to configure how metrics and methods show
  As a provider
  I want to be able to change their looks

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" uses backend v1 in his default service
    Given provider "foo.example.com" has plans already ready for signups
    Given the metrics with usage limits of plan "application_plan":
      | metric  |
      | visible |
      | another |
    And the metrics without usage limits of plan "application_plan":
      | metric  |
      | no_usage_limits |

    And a buyer "buyer" signed up to provider "foo.example.com"
    And buyer "buyer" has application "app"

  #are this kind of scenario really needed?
  Scenario: Metrics without limits appear in Unlimited Metrics section
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I go to the edit page for plan "application_plan"
    Then I should see the metric "no_usage_limits" is visible

    When I go to the provider side "app" application page
    Then I should see the unlimited metric "no_usage_limits" in the plan widget

    # When I log in as "buyer" on "foo.example.com"
    #   And I go to the "app" application page
    # Then I should see the unlimited metric "no_usage_limits" in the plan widget

  Scenario: Metrics without limits should not appear if set to invisible
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I go to the edit page for plan "application_plan"
    Then I should see the metric "no_usage_limits" is visible

    When I go to the provider side "app" application page
    Then I should see the unlimited metric "no_usage_limits" in the plan widget

    # When I log in as "buyer" on "foo.example.com"
    #   And I go to the "app" application page
    # Then I should see the unlimited metric "no_usage_limits" in the plan widget

