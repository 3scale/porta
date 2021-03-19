@javascript
Feature: Plan publishing
  In order to allow people to sign up for a plan
  As a provider
  I want to publish it

  Background:
    Given a provider "foo.3scale.localhost"

  @wip
  Scenario: Published plans shows in public
    Given a published plan "Public Plan" of provider "foo.3scale.localhost"

  Scenario: Publish an Application plan
    Given a hidden plan "Awesome" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the application plans admin page
    And I select option "Publish" from the actions menu for plan "Awesome"
    Then I should see "Plan Awesome was published."
    And I should see a published plan "Awesome"
    And plan "Awesome" should be published
    And I should not see option "Publish" from the actions menu for plan "Awesome"

  @wip
  Scenario: Publish a Service plan

  @wip
  Scenario: Publish an Account plan
