Feature: Plan hiding
  In order to stop people from signing up to a plan anymore
  As a provider
  I want to hide it

  Background:
    Given a provider "foo.3scale.localhost"

  #TODO using 'I go to the plans page' because I don't know how to navigate to those in the public side
  @wip
  Scenario: Hidden plans does not show in public
    Given a hidden plan "Hidden" of provider "foo.3scale.localhost"
      And the current domain is "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has no default account plan
    When I go to the plans page
    Then I should see there are no plans available

  #TODO test it for other plan types
  Scenario: Hide a plan
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

    Given a published plan "Awesome" of provider "foo.3scale.localhost"
      And I go to the application plans admin page
      And I follow "Hide" for plan "Awesome"
    Then I should see "Plan Awesome was hidden."
      And I should see a hidden plan "Awesome"
      And plan "Awesome" should be hidden
