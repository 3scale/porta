@javascript
Feature: Quick Starts

   Rule: Feature is enabled
    Background:
      Given quickstarts is enabled
      And a provider is logged in

    Scenario: Header help menu have the option
      Then I should be able to go to the quick start catalog from the help menu

    Scenario: Quick start button is displayed
      When they go to the dashboard
      And they follow "Quick starts"
      Then the current page is the quick start catalog page

    @narrow-screen
    Scenario: Quick start button is not displayed on narrow screens
      When they go to the dashboard
      Then they should not see "Quick starts"

    Scenario: Quick Start catalog
      Given I go to the quick start catalog page
      Then I should be able to start following a quick start from a gallery

    Scenario: Following a Quick Start
      Given I am following a quick start
      When I go anywhere else
      Then I will still be able to see the quick start

    Scenario: Closing a Quick Start
      Given I am following a quick start
      Then I should be able to close it without losing any progress

    Scenario: Restart a Quick Start
      Given I have finished a quick start
      Then I should be able to restart its progress

    Scenario: Provider logs in for the first time
      Given they should see the flash message "You can use quick starts to learn about 3scale features step by step."
      When they follow "Take tour"
      Then the current page is the quick start catalog page

    Scenario: Provider reloads dashboard
      Given they should see the flash message "You can use quick starts to learn about 3scale features step by step."
      When they go to the dashboard
      And they should not see "You can use quick starts to learn about 3scale features step by step."

    Scenario: Provider logs in more than once
      When they log out
      And the provider logs in
      Then they should see the flash message "Signed in successfully"
      And they should not see "You can use quick starts to learn about 3scale features step by step."

  Rule: Quickstarts disabled
    Background:
      Given quickstarts is disabled
      And a provider is logged in

    Scenario: Header help menu does not have the option
      Then I should not be able to go to the quick start catalog from the help menu

    Scenario: Quick start button is not displayed
      When they go to the dashboard
      Then they should not see "Quick starts"

    Scenario: Following a Quick Start does not show it
      Given I am following a quick start
      When I go anywhere else
      Then I won't be able to see the quick start

    Scenario: Provider logs in for the first time
      Then they should see the flash message "Signed in successfully"
      And they should not see "You can use quick starts to learn about 3scale features step by step."
