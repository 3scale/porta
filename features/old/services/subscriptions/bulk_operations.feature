@javascript @ajax
Feature: Bulk operations
  In order to control a lot of subscibed services
  As a provider
  I want to make bulk operations

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "service_plans" visible
      And a default service of provider "foo.example.com" has name "Fancy API"
      And a service "New Service" of provider "foo.example.com"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.example.com":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    Given current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"

  Scenario: Show and hide bulk operations controls
     And provider "foo.example.com" has "service_plans" visible
     When I go to the subscriptions admin page
    When I check select for "bob"
    Then "Bulk operations" should be visible
      And I should see "Send email"
      And I should see "Change service plan"
      And I should see "Change state"
      #And I should see "Delete"
    When I uncheck select for "bob"
    Then "Bulk operations" should not be visible

  Scenario: Check all applications with main checkbox
      And I am on the service contracts admin page
    When I check select in table header

    Then all selects should be checked
      And "Bulk operations" should be visible

    When I uncheck select in table header
    Then none selects should be checked
      And "Bulk operations" should not be visible
