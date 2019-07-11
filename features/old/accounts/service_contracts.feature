Feature: Account service plans management
  In order to know what services are accounts signed up for
  As a provider
  I want to have listing of service contracts and possibilit to create one or change plan

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "service_plans" visible

    Given a default service of provider "foo.example.com" has name "Regular API"
      And a service "Fancy API" of provider "foo.example.com"

    Given a service plan "Only one" for service "Regular API" exists
      And service plan "Only one" is default

    Given a service plan "Expensive one" for service "Fancy API" exists
      And a service plan "Cheap one" for service "Fancy API" exists
      And service plan "Cheap one" is default

    Given a buyer "bob" signed up to provider "foo.example.com"
    Given current domain is the admin domain of provider "foo.example.com"

  Scenario: Link to service contracts on account page in enterprise
    Given I am logged in as provider "foo.example.com"
    When I am on the buyer account page for "bob"
     And I follow "Portal" in the main menu
    Then I should see "Service Subscription"

  @javascript @ajax
  Scenario: Subscribe to service with selected service plan
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"

    When I am on the buyer account service contracts page for "bob"

    Then I should see "Service subscriptions of bob"
     And I should see "Regular API"
     And I should see "Fancy API"

    When I follow "Subscribe to Fancy API"

    Then I should see "New service subscription"
    #And I should see "Cheap one"
    #And I should see "Expensive one"

    When I press "Create subscription"
    Then I should see "Cheap one"

    When I follow "Change Fancy API subscription"
    Then I should see "Change subscribed plan"

    When I select "Expensive one" from "Plan"
     And I press "Change subscription" within fancybox
    Then I should see "Expensive one"


