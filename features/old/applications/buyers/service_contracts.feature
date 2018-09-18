Feature: Buyer subscribes to service and can create applications for that service
  In order to to create applications for specific service
  As a buyer
  I have to subscribe a service and have contract approved

  Background:
    Given a provider "foo.example.com"
      And a default service of provider "foo.example.com" has name "API"
      And a service plan "Gold" for service "API" exists
      And a published application plan "Default" for service "API" exists
    Given the current domain is "foo.example.com"

  Scenario: Buyer subscribes service with approval required
    Given service plan "Gold" requires approval of contracts
      And a buyer "bob" signed up to service plan "Gold"
      And I am logged in as "bob"
     When I go to the applications page
     Then I should not see "Create new application"

     When the contract of buyer "bob" with plan "Gold" is approved
      And I go to the applications page
     Then I should see "Create new application"
