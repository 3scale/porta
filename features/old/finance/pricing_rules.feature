@javascript
Feature: On paid plans
  In order to charge my customers
  As a provider
  I want to charge my customers the right amounts

  Background:
    Given a provider is logged in
    And the provider is charging its buyers
    And an application plan "Rocket" of provider "foo.3scale.localhost"

  Scenario: Pricing rules have 4 decimals of precision
    Given pricing rules on plan "Rocket":
      | Metric | Cost per unit | Min | Max      |
      | hits   |        0.0001 |   1 | infinity |
    When I go to the edit page for plan "Rocket"
    And I follow "Pricing (1)"
    Then I should see "0.0001"
