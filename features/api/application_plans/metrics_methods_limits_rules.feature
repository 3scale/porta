@javascript
Feature: Application plan Metrics, Methods, Limits & Pricing Rules

  Background:
    Given a provider is logged in
    And a product "Dice rolls"
    And the provider has "service_plans" allowed
    And the provider has "account_plans" allowed
    And the following application plan:
      | Product    | Name | Default |
      | Dice rolls | Free | true    |
    And the product has the following metrics:
      | Friendly name    |
      | Single rolls     |
      | Repeated rolls   |
      | Complex rolls    |
      | Custom dice roll |

  Scenario: Pricing rules are hidden when billing disabled
    Given they go to application plan "Free" admin edit page
    Then they should see "Metrics, Methods & Limits"

  Scenario: Pricing rules are visible when billing enabled
    Given the provider is charging its buyers
    When they go to application plan "Free" admin edit page
    Then they should see "Metrics, Methods, Limits & Pricing Rules"

  Scenario: Hiding usage limits
    Given application plan "Free" has defined the following usage limit:
      | Metric       | Period | Max. value |
      | Single rolls | hour   | 30         |
    And application plan "Free" should have visible usage limits
    When they go to application plan "Free" admin edit page
    And follow "Make metric Single rolls invisible"
    And wait a moment
    Then application plan "Free" should not have visible usage limits

  Scenario: Adding usage limits
    Given they go to application plan "Free" admin edit page
    When they follow "Edit limits of Hits"
    And follow "New usage limit"
    And the modal is submitted with:
      | Period     | minute |
      | Max. value | 10     |
    Then they should see the flash message "Usage Limit has been created"
    And should see the following table that belongs to metric "Hits" usage limits:
      | Period   | Value |
      | 1 minute | 10    |

  @wip
  Rule: with application
    Background:
      Given a buyer "Goodman James"
      And the following application:
        | Buyer         | Name       | Plan |
        | Goodman James | RPG-online | Free |

    Scenario: Metrics without limits appear in Unlimited Metrics section
      Given application plan "Free" has no usage limits for metric "Single rolls"
      When they go to the application's admin page
      Then they should see the unlimited metric "Single rolls" in the plan widget

    Scenario: Metrics without limits should not appear if set to invisible
      Given they go to application plan "Free" admin edit page
      Then I should see the metric "no_usage_limits" is visible
      When they go to the application's admin page
      Then I should see the unlimited metric "no_usage_limits" in the plan widget

    Scenario: All metrics are visible by default
      Given they go to application plan "Free" admin edit page
      Then I should see the metric "visible" is visible
      When they go to the application's admin page
      Then I should see the metric "visible" in the plan widget

    Scenario: Hide metric
      Given they go to application plan "Free" admin edit page
      When I hide the metric "another"
      Then I should see the metric "another" is hidden
      When they go to the application's admin page
      Then I should see the metric "visible" in the plan widget
      But I should not see the metric "another" in the plan widget

    Scenario: All metrics limits are shown with text by default
      Given they go to application plan "Free" admin edit page
      Then I should see the metric "visible" limits show as text
      When they go to the application's admin page
      Then I should see the metric "visible" limits as text in the plan widget

    Scenario: Metric limits shown with icon and text
      Given they go to application plan "Free" admin edit page
      When I change the metric "visible" to show with icons and text
      Then I should see the metric "visible" limits show as icons and text
      When they go to the application's admin page
      Then I should see the metric "visible" limits as icons and text in the plan widget

    Scenario: Metric limits with value 0 only show icons in icons and text mode
      Given plan "application_plan" has defined the following usage limits:
        | Metric | Period | Max. value |
        | zeroed | day    | 0          |
      Given they go to application plan "Free" admin edit page
      When I change the metric "zeroed" to show with icons and text
      Then I should see the metric "zeroed" limits show as icons and text
      When they go to the application's admin page
      Then I should see the metric "zeroed" limits as icons only in the plan widget

    Scenario: Metrics enabling and disabling
      Given plan "application_plan" has defined the following usage limits:
        | Metric | Period | Max. value |
        | zeroed | day    | 0          |
      Given they go to application plan "Free" admin edit page
      Then I should see the metric "visible" is enabled
      But I should see the metric "zeroed" is disabled
      When I enable the metric "zeroed"
      And I disable the metric "visible"
      Then I should see the metric "zeroed" is enabled
      But I should see the metric "visible" is disabled

    Scenario: Metric cannot be disabled
      Given plan "application_plan" has defined all usage limits for "zeroed"
      Given they go to application plan "Free" admin edit page
      Then I should see the metric "zeroed" is enabled
      When I disable the metric "zeroed"
      Then I should see the metric "zeroed" is enabled
      And I should see "Metric cannot be disabled. Please contact support."
