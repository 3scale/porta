@javascript
Feature: Dashboard

  Background:
    Given a provider is logged in

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

  Scenario: Navigation
    When they go to the dashboard
    And they follow "Quick starts"
    Then the current page is the quick start catalog page
