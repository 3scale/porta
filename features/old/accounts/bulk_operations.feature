@javascript @ajax
Feature: Bulk operations
  In order to control a lot of applications
  As a provider
  I want to make bulk operations

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "account_plans" switch visible


    Given these buyers signed up to provider "foo.example.com"
      | bob  |
      | jane |

    Given current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"

  Scenario: Show and hide bulk operations controls
    When I navigate to the accounts page
    When I check select for "bob"
    Then "Bulk operations" should be visible
      And I should see "Send email"
      And I should see "Change account plan"
      And I should see "Change state"
    When I uncheck select for "bob"
    Then "Bulk operations" should not be visible

  Scenario: Check all accounts with main checkbox
      And I am on the accounts admin page

    When I check select in table header

    Then all selects should be checked
      And "Bulk operations" should be visible

    When I uncheck select in table header
    Then none selects should be checked
      And "Bulk operations" should not be visible
