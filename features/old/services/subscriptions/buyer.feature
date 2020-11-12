Feature: Buyer's service subscription
  In order to use some API when in multiservice settings
  As buyer
  I want to be able to subscribe to a service

  Background:
    Given all the rolling updates features are off
    Given a provider "foo.3scale.localhost"

    And provider "foo.3scale.localhost" has "multiple_services" visible
    And a service "Second" of provider "foo.3scale.localhost"
    And a buyer "bob" of provider "foo.3scale.localhost"
    And a published service plan "SoundsLike" of service "API" of provider "foo.3scale.localhost"
    And I log in as "bob" on "foo.3scale.localhost"

  Scenario: Simple subscription
   Given a published service plan "AnotherOne" of service "API" of provider "foo.3scale.localhost"
     And I go to the service subscription page
     And I press "Subscribe"
    Then I should see "You have successfully subscribed to a service."

  Scenario: Subscription with approval
   Given a published service plan "Platinum" of service "Second" of provider "foo.3scale.localhost"
     And service plan "Platinum" requires approval

    When I go to the service subscription page
     And I select "Platinum" from "Plan"
     And press "Subscribe"
    Then I should see "You have successfully subscribed to a service."
     And I should see "Platinum (pending)"

  Scenario: Subscribe with legal terms
    Given provider "foo.3scale.localhost" has service subscription legal terms:
     """
     <h1>Magna Charta Libertatum</h1>
     <p>All your base are belong to us.</p>
     """
    And a published service plan "Cool" of service "Second"

    When I go to the service subscription page
    Then I should see "Magna Charta"
     And I press "Subscribe"
    Then I should see "You have successfully subscribed to a service."

  Scenario: Fast lane - automatically subscribed when there is no plan to choose from
    When I log in as "bob" on "foo.3scale.localhost"
     And I go to the service subscription page
    Then I should see "You have successfully subscribed to a service."
