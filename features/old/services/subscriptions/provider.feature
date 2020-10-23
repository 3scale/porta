Feature: Service subscriptions - providers
  In order to subscribe/unsubscribe my customers from services
  As a provider
  I want to be able to liservice subscriptions

  Background:
      And a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "service_plans" visible
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And a service "Elephant Taming" of provider "foo.3scale.localhost"
      And a service "Zeebra Stripe Drawing" of provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"

  Scenario: Listing contracts by service
    When I go to the service subscriptions list for provider
     And I select "Elephant Taming" from "Service"
     And I press "Search"
    Then I should see "No results."

  Scenario: Listing contracts by service
   Given a buyer "mouse" of provider "foo.3scale.localhost"
      And buyer "mouse" subscribed service "Elephant Taming"

    When I go to the service subscriptions list for provider
     And I select "Elephant Taming" from "Service"
     And I press "Search"
    Then I should see "mouse"
    Then I should not see "Zeebra Stripe Drawing" within the results

