@javascript @ignore-backend
Feature: Product > Applications > Application Plans > Edit
  Background:
    Given a provider is logged in
    And the provider has plans ready for signups
    And the metrics with usage limits of plan "application_plan":
      | metric  |
      | visible |
      | another |
    And the metrics without usage limits of plan "application_plan":
      | metric          |
      | no_usage_limits |
    And a buyer "buyer" signed up to provider "foo.3scale.localhost"
    And buyer "buyer" has application "app"

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

  Scenario: All metrics are visible by default
    And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" is visible
    When I go to the provider side "app" application page
    Then I should see the metric "visible" in the plan widget

  Scenario: Hide metric
    And I go to the edit page for plan "application_plan"
    When I hide the metric "another"
    Then I should see the metric "another" is hidden
    When I go to the provider side "app" application page
    Then I should see the metric "visible" in the plan widget
    But I should not see the metric "another" in the plan widget

  Scenario: All metrics limits are shown with text by default
    And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" limits show as text
    When I go to the provider side "app" application page
    Then I should see the metric "visible" limits as text in the plan widget

  Scenario: Metric limits shown with icon and text
    And I go to the edit page for plan "application_plan"
    When I change the metric "visible" to show with icons and text
    Then I should see the metric "visible" limits show as icons and text
    When I go to the provider side "app" application page
    Then I should see the metric "visible" limits as icons and text in the plan widget

  Scenario: Metric limits with value 0 only show icons in icons and text mode
    Given the metric "zeroed" with usage limit 0 of plan "application_plan"
    And I go to the edit page for plan "application_plan"
    When I change the metric "zeroed" to show with icons and text
    Then I should see the metric "zeroed" limits show as icons and text
    When I go to the provider side "app" application page
    Then I should see the metric "zeroed" limits as icons only in the plan widget

  Scenario: Metrics enabling and disabling
    Given the metric "zeroed" with usage limit 0 of plan "application_plan"
    And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" is enabled
    But I should see the metric "zeroed" is disabled
    When I enable the metric "zeroed"
    And I disable the metric "visible"
    Then I should see the metric "zeroed" is enabled
    But I should see the metric "visible" is disabled

  Scenario: Metric cannot be disabled
    Given the metric "zeroed" with all used periods of plan "application_plan"
    And I go to the edit page for plan "application_plan"
    Then I should see the metric "zeroed" is enabled
    When I disable the metric "zeroed"
    Then I should see the metric "zeroed" is enabled
    And I should see "Metric cannot be disabled. Please contact support."
