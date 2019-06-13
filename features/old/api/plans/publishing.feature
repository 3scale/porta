Feature: Plan publishing
  In order to allow people to sign up for a plan
  As a provider
  I want to publish it

  Background:
    Given a provider "foo.example.com"

  #TODO using 'I go to the plans page' because I don't know how to navigate to those in the public side
  @wip
  Scenario: Published plans shows in public
    Given a published plan "Published" of provider "foo.example.com"
      And provider "foo.example.com" has no default account plan
      And the current domain is "foo.example.com"
    When I go to the plans page
    Then I should see the details of plan "Published"

  #TODO test it for other plan types
  # TODO navigate instead of go to - uses default_service
  Scenario: Publish a plan
    Given a hidden plan "Awesome" of provider "foo.example.com"

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

      And I go to the application plans admin page
      And I follow "Publish" for plan "Awesome"
    Then I should see "Plan Awesome was published."
      And I should see a published plan "Awesome"
      And plan "Awesome" should be published
