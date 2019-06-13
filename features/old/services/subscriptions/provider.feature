Feature: Service subscriptions - providers
  In order to subscribe/unsubscribe my customers from services
  As a provider
  I want to be able to liservice subscriptions

  Background:
      And a provider "foo.example.com"
      And provider "foo.example.com" has "service_plans" visible
      And current domain is the admin domain of provider "foo.example.com"
      And a service "Elephant Taming" of provider "foo.example.com"
      And a service "Zeebra Stripe Drawing" of provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

  # Regression test for https://3scale.airbrake.io/errors/23463933
  #
  Scenario: Listing contracts by service
    When I go to the service subscriptions list for provider
     And I select "Elephant Taming" from "Service"
     And I press "Search"
    Then I should see "No results."

  Scenario: Listing contracts by service
   Given a buyer "mouse" of provider "foo.example.com"
      And buyer "mouse" subscribed service "Elephant Taming"

    When I go to the service subscriptions list for provider
     And I select "Elephant Taming" from "Service"
     And I press "Search"
    Then I should see "mouse"
    Then I should not see "Zeebra Stripe Drawing" within the results

