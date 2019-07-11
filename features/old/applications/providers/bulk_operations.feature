@javascript @ajax
Feature: Bulk operations
  In order to control a lot of applications
  As a provider
  I want to make bulk operations

  Background:
    Given a provider "foo.example.com"
    Given a default application plan "Basic" of provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "service_plans" switch allowed

    Given a following buyers with applications exists:
      | name | provider        | applications |
      | bob  | foo.example.com | BobApp       |
      | jane | foo.example.com | JaneApp      |

    Given current domain is the admin domain of provider "foo.example.com"
      And I don't care about application keys

  Scenario: Show and hide bulk operations controls
    Given I am logged in as provider "foo.example.com"

    When I go to the applications admin page
    When I check select for "BobApp"
    Then "Bulk operations" should be visible
      And I should see "Send email"
      And I should see "Change application plan"
      And I should see "Change state"
      #And I should see "Delete"
    When I uncheck select for "BobApp"
    Then "Bulk operations" should not be visible

  Scenario: Check all applications with main checkbox
    Given I am logged in as provider "foo.example.com"
      And I am on the applications admin page

    When I check select in table header

    Then all selects should be checked
      And "Bulk operations" should be visible

    When I uncheck select in table header
    Then none selects should be checked
      And "Bulk operations" should not be visible
