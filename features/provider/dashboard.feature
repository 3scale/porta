@javascript
Feature: Dashboard

  Background:
    Given a provider is logged in

  Scenario: On first login provider should see a quickstart info notification
    Then they should see "You can use quick starts to learn about 3scale features step by step."

  Scenario: Navigation
    When they go to the dashboard
    And they follow "Quickstarts"
    Then the current page is the quick start catalog page
