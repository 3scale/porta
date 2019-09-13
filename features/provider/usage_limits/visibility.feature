@javascript
Feature: Usage limits visibility
  In order to present limits to my customers
  As a provider
  I need to configure visibility of usage limits

  Background:
    Given a provider is logged in

  Scenario: Create a limit
    Given the provider creates a plan
      And makes hits invisible for that plan
      And the plan should not have visible usage limits
    When the provider creates a plan
     And limits hits of that plan to 10
    Then the plan should have visible usage limits
