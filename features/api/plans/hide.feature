@javascript
Feature: Plan hiding
  In order to stop people from signing up to a plan anymore
  As a provider
  I want to hide it

  Background:
    Given a provider "foo.3scale.localhost"

  @wip
  Scenario: Hidden plans does not show in public
    Given a hidden plan "Secret Plan" of provider "foo.3scale.localhost"

  Scenario: Hide an application plan
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    Given a published plan "Awesome" of provider "foo.3scale.localhost"
    And I go to the application plans admin page
    And I select option "Hide" from the actions menu for plan "Awesome"
    Then I should see "Plan Awesome was hidden."
    And I should see a hidden plan "Awesome"
    And plan "Awesome" should be hidden
    And I should not see option "Hide" from the actions menu for plan "Awesome"

  @wip
  Scenario: Hide a Service plan

  @wip
  Scenario: Hide an Account plan
