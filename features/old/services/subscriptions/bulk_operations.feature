@javascript
Feature: Bulk operations
  In order to control a lot of subscibed services
  As a provider
  I want to make bulk operations

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "service_plans" visible
      And a default service of provider "foo.3scale.localhost" has name "Fancy API"
      And a service "New Service" of provider "foo.3scale.localhost"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.3scale.localhost":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    Given current domain is the admin domain of provider "foo.3scale.localhost"
    Given I am logged in as provider "foo.3scale.localhost"

  # FIXME: THREESCALE-7195 this scenario is failing in CircleCI. We need to refactor it as an integration test.
  @wip
  Scenario: Show and hide bulk operations controls
     And provider "foo.3scale.localhost" has "service_plans" visible
     When I go to the subscriptions admin page
    When I check select for "bob"
    Then "Bulk operations" should be visible
      And I should see "Send email"
      And I should see "Change service plan"
      And I should see "Change state"
    When I uncheck select for "bob"
    Then "Bulk operations" should not be visible

  # FIXME: THREESCALE-7195 this scenario is failing in CircleCI. We need to refactor it as an integration test.
  @wip
  Scenario: Check all applications with main checkbox
      And I am on the service contracts admin page
    When I check select in table header

    Then all selects should be checked
      And "Bulk operations" should be visible

    When I uncheck select in table header
    Then none selects should be checked
      And "Bulk operations" should not be visible
