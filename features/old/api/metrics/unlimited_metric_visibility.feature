@ignore-backend @javascript
Feature: Metric visibility
  In order to configure how metrics and methods show
  As a provider
  I want to be able to change their looks

  Background:
    Given a provider is logged in
    And the provider has multiple applications enabled
    And the provider uses backend v1 in his default service
    Given provider "foo.3scale.localhost" has plans already ready for signups
    Given the metrics with usage limits of plan "application_plan":
      | metric  |
      | visible |
      | another |
    And the metrics without usage limits of plan "application_plan":
      | metric          |
      | no_usage_limits |

    And a buyer "buyer" signed up to provider "foo.3scale.localhost"
    And buyer "buyer" has application "app"

  #are this kind of scenario really needed?
  Scenario: Metrics without limits appear in Unlimited Metrics section
    And I go to the edit page for plan "application_plan"
    Then I should see the metric "no_usage_limits" is visible
    When I go to the provider side "app" application page
    Then I should see the unlimited metric "no_usage_limits" in the plan widget

  Scenario: Metrics without limits should not appear if set to invisible
    And I go to the edit page for plan "application_plan"
    Then I should see the metric "no_usage_limits" is visible
    When I go to the provider side "app" application page
    Then I should see the unlimited metric "no_usage_limits" in the plan widget
