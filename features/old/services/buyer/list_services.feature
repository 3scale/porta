Feature: Buyer's service subscription
  As a buyer
  I wan to subscribe and unsubscribe from any service of my provider

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_services" visible
    And a service "Frutas" of provider "foo.3scale.localhost"
    And a service "Verduras" of provider "foo.3scale.localhost"

    And a published account plan "Pakistani" of provider "foo.3scale.localhost"
    And a published service plan "Melon" of service "Frutas"
    And a published service plan "Tomato" of service "Verduras"
    And a published service plan "Pepper" of service "Verduras"

    And a buyer "bob" signed up to account plan "Pakistani"

   Scenario: Services that do not allow contracts are not visible to buyers
     Given a service "NoContractsService" of provider "foo.3scale.localhost"
     When I log in as "bob" on "foo.3scale.localhost"
      And I go to the services list for buyers
      Then I should see "Frutas"
       And I should see "Verduras"
      But I should not see "NoContractsService"

   Scenario: List services and subscribe to one of them
     When I log in as "bob" on "foo.3scale.localhost"
      And I go to the services list for buyers

      Then I should see "Frutas"
       And I should see "Verduras"

      When I follow "Subscribe to Verduras"
       And I select "Tomato" from "Plan"
       And I press "Subscribe"
      Then I should see "You have successfully subscribed to a service."

      When I go to the services list for buyers
      Then I should not see "Subscribe to Verduras"
