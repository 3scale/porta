@javascript
Feature: Account service plans management
  In order to know what services are accounts signed up for
  As a provider
  I want to have listing of service contracts and possibilit to create one or change plan

  Background:
    Given a provider is logged in
    And the provider has multiple applications enabled
    And the provider has "service_plans" visible
    Given a default service of provider "foo.3scale.localhost" has name "Regular API"
    And a service "Fancy API" of provider "foo.3scale.localhost"
    Given a service plan "Only one" for service "Regular API" exists
    And service plan "Only one" is default
    Given a service plan "Expensive one" for service "Fancy API" exists
    And a service plan "Cheap one" for service "Fancy API" exists
    And service plan "Cheap one" is default
    Given a buyer "bob" signed up to provider "foo.3scale.localhost"

  Scenario: Link to service contracts on account page in enterprise
    When I am on the buyer account page for "bob"
    And I should see menu items under "Developer Portal"
      | Content              |
      | Drafts               |
      | Redirects            |
      | Feature Visibility   |
      | ActiveDocs           |
      | Visit Portal         |
      | Signup               |
      | Service Subscription |
      | New Application      |
      | Domains & Access     |
      | Spam Protection      |
      | SSO Integrations     |
      | Liquid Reference     |

  Scenario: Subscribe to service with selected service plan
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
