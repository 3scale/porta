Feature: On paid plans
  In order to charge my customers
  As a provider
  I want to charge my customers the right amounts

  Background:
    Given a provider "planet.express.com" with billing enabled
    And provider "planet.express.com" is charging
    And provider "planet.express.com" has "finance" switch visible
    And an application plan "Rocket" of provider "planet.express.com"
    And current domain is the admin domain of provider "planet.express.com"
    And I am logged in as provider "planet.express.com"

  Scenario: Pricing rules have 4 decimals of precision
    Given pricing rules on plan "Rocket":
      | Metric | Cost per unit | Min | Max      |
      | hits   |        0.0001 |   1 | infinity |
    When I go to the edit page for plan "Rocket"
    And I follow "Pricing (1)"
    Then I should see "0.0001"
