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

    And a buyer "buyer" signed up to provider "foo.example.com"
    And buyer "buyer" has application "app"

  #are this kind of scenario really needed?
  Scenario: All metrics are visible by default
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" is visible
    When I go to the provider side "app" application page
    Then I should see the metric "visible" in the plan widget

  # TODO: Test for presence of metric in lightbox widget buyer side
  #   When I log in as "buyer" on "foo.example.com"
  #     And I go to the "app" application page
  #   Then I should see the metric "visible" in the plan widget

  @javascript @ajax
  Scenario: Hide metric
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I go to the edit page for plan "application_plan"
    When I hide the metric "another"
    Then I should see the metric "another" is hidden

    When I go to the provider side "app" application page
    Then I should see the metric "visible" in the plan widget
      But I should not see the metric "another" in the plan widget

    # TODO: Test for absence of metric in lightbox widget buyer side
    # When I log in as "buyer" on "foo.example.com"
    # And I go to the "app" application page
    # Then I should see the metric "visible" in the plan widget
    #   But I should not see the metric "another" in the plan widget

  #are this kind of scenario really needed?
  Scenario: All metrics limits are shown with text by default
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

      And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" limits show as text

    When I go to the provider side "app" application page
    Then I should see the metric "visible" limits as text in the plan widget

    # TODO: Test for presence of metric in lightbox widget buyer side
    # When I log in as "buyer" on "foo.example.com"
    #   And I go to the "app" application page
    # Then I should see the metric "visible" limits as text in the plan widget

  @javascript @ajax
  Scenario: Metric limits shown with icon and text
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    And I go to the edit page for plan "application_plan"
    When I change the metric "visible" to show with icons and text
    Then I should see the metric "visible" limits show as icons and text

    When I go to the provider side "app" application page
    Then I should see the metric "visible" limits as icons and text in the plan widget

    # When the current domain is foo.example.com
    # When I log in as "buyer" on "foo.example.com"
    #   And I go to the "app" application page
    # Then I should see the metric "visible" limits as icons and text in the plan widget

  @javascript @ajax
  Scenario: Metric limits with value 0 only show icons in icons and text mode
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    Given the metric "zeroed" with usage limit 0 of plan "application_plan"
      And I go to the edit page for plan "application_plan"
    When I change the metric "zeroed" to show with icons and text
    Then I should see the metric "zeroed" limits show as icons and text

    When I go to the provider side "app" application page
    Then I should see the metric "zeroed" limits as icons only in the plan widget

    # When the current domain is foo.example.com
    # When I log in as "buyer" on "foo.example.com"
    #   And I go to the "app" application page
    # Then I should see the metric "zeroed" limits as icons only in the plan widget

  @javascript @ajax
  Scenario: Metrics enabling and disabling
    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

    Given the metric "zeroed" with usage limit 0 of plan "application_plan"
      And I go to the edit page for plan "application_plan"
    Then I should see the metric "visible" is enabled
      But I should see the metric "zeroed" is disabled

    When I enable the metric "zeroed"
      And I disable the metric "visible"
    Then I should see the metric "zeroed" is enabled
      But I should see the metric "visible" is disabled

  @javascript @ajax
    Scenario: Metric cannot be disabled
      Given current domain is the admin domain of provider "foo.example.com"
        And I log in as provider "foo.example.com"

      Given the metric "zeroed" with all used periods of plan "application_plan"
        And I go to the edit page for plan "application_plan"
      Then I should see the metric "zeroed" is enabled

      When I disable the metric "zeroed"
      Then I should see the metric "zeroed" is enabled
        And I should see "Metric cannot be disabled. Please contact support."
