@wip
Feature: Signup terms and conditions
  In order to don't be sued by clients
  As a provider
  I want to put terms and conditions on the signup page

  Scenario: Plan with service specific terms only
    Given a provider "goo.3scale.localhost"
    And the service of provider "goo.3scale.localhost" has terms
    And an application plan "Basic" of provider "goo.3scale.localhost"
    When I am on goo.3scale.localhost
    And I go to the sign up page for the "Basic" plan
    Then I should see "terms and conditions (service specific)"
    And I should not see "terms and conditions (plan specific)"

  Scenario: Plan with plan specific terms only
    Given a provider "goo.3scale.localhost"
    And an application plan "Basic" of provider "goo.3scale.localhost"
    And plan "Basic" has terms
    When I am on goo.3scale.localhost
    And I go to the sign up page for the "Basic" plan
    Then I should not see "terms and conditions (service specific)"
    And I should see "terms and conditions (plan specific)"

  Scenario: Plan with both service and plan specific terms
    Given a provider "goo.3scale.localhost"
    And the service of provider "goo.3scale.localhost" has terms
    And an application plan "Basic" of provider "goo.3scale.localhost"
    And plan "Basic" has terms
    When I am on goo.3scale.localhost
    And I go to the sign up page for the "Basic" plan
    Then I should see "terms and conditions (service specific)"
    And I should see "terms and conditions (plan specific)"
