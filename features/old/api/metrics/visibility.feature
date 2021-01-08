@ignore-backend
Feature: Metric visibility
  In order to configure how metrics and methods show
  As a provider
  I want to be able to change their looks

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And provider "foo.3scale.localhost" uses backend v1 in his default service
    Given provider "foo.3scale.localhost" has plans already ready for signups
    Given the metrics with usage limits of plan "application_plan":
      | metric  |
      | visible |
      | another |

    And a buyer "buyer" signed up to provider "foo.3scale.localhost"
    And buyer "buyer" has application "app"

  #are this kind of scenario really needed?
  Scenario: All metrics are visible by default
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
      And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" is visible
    When I go to the provider side "app" application page
    Then I should see the metric "visible" in the plan widget

  # TODO: Test for presence of metric in lightbox widget buyer side
  #   When I log in as "buyer" on "foo.3scale.localhost"
  #     And I go to the "app" application page
  #   Then I should see the metric "visible" in the plan widget

  @javascript
  Scenario: Hide metric
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
      And I go to the edit page for plan "application_plan"
    When I hide the metric "another"
    Then I should see the metric "another" is hidden

    When I go to the provider side "app" application page
    Then I should see the metric "visible" in the plan widget
      But I should not see the metric "another" in the plan widget

    # TODO: Test for absence of metric in lightbox widget buyer side
    # When I log in as "buyer" on "foo.3scale.localhost"
    # And I go to the "app" application page
    # Then I should see the metric "visible" in the plan widget
    #   But I should not see the metric "another" in the plan widget

  #are this kind of scenario really needed?
  Scenario: All metrics limits are shown with text by default
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

      And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" limits show as text

    When I go to the provider side "app" application page
    Then I should see the metric "visible" limits as text in the plan widget

    # TODO: Test for presence of metric in lightbox widget buyer side
    # When I log in as "buyer" on "foo.3scale.localhost"
    #   And I go to the "app" application page
    # Then I should see the metric "visible" limits as text in the plan widget

  @javascript
  Scenario: Metric limits shown with icon and text
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

    And I go to the edit page for plan "application_plan"
    When I change the metric "visible" to show with icons and text
    Then I should see the metric "visible" limits show as icons and text

    When I go to the provider side "app" application page
    Then I should see the metric "visible" limits as icons and text in the plan widget

    # When the current domain is "foo.3scale.localhost"
    # When I log in as "buyer" on "foo.3scale.localhost"
    #   And I go to the "app" application page
    # Then I should see the metric "visible" limits as icons and text in the plan widget

  @javascript
  Scenario: Metric limits with value 0 only show icons in icons and text mode
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

    Given the metric "zeroed" with usage limit 0 of plan "application_plan"
      And I go to the edit page for plan "application_plan"
    When I change the metric "zeroed" to show with icons and text
    Then I should see the metric "zeroed" limits show as icons and text

    When I go to the provider side "app" application page
    Then I should see the metric "zeroed" limits as icons only in the plan widget

    # When the current domain is "foo.3scale.localhost"
    # When I log in as "buyer" on "foo.3scale.localhost"
    #   And I go to the "app" application page
    # Then I should see the metric "zeroed" limits as icons only in the plan widget

  @javascript
  Scenario: Metrics enabling and disabling
    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"

    Given the metric "zeroed" with usage limit 0 of plan "application_plan"
      And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" is enabled
      But I should see the metric "zeroed" is disabled

    When I enable the metric "zeroed"
      And I disable the metric "visible"
    Then I should see the metric "zeroed" is enabled
      But I should see the metric "visible" is disabled

  @javascript
    Scenario: Metric cannot be disabled
      Given current domain is the admin domain of provider "foo.3scale.localhost"
        And I log in as provider "foo.3scale.localhost"

      Given the metric "zeroed" with all used periods of plan "application_plan"
        And I go to the edit page for plan "application_plan"
      Then I should see the metric "zeroed" is enabled

      When I disable the metric "zeroed"
      Then I should see the metric "zeroed" is enabled
        And I should see "Metric cannot be disabled. Please contact support."
