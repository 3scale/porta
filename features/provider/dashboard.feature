@javascript
Feature: Dashboard

  Background:
    Given a provider is logged in

  Scenario: On first login provider should see a quick starts info notification
    Given they should see "You can use quick starts to learn about 3scale features step by step."
    When they follow "Take tour"
    Then the current page is the quick start catalog page

  Scenario: On second login provider should not see a quick starts info notification
    Then they should not see "You can use quick starts to learn about 3scale features step by step."

  Scenario: Navigation
    When they go to the dashboard
    And they follow "Quick starts"
    Then the current page is the quick start catalog page
