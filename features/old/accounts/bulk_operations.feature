@javascript
Feature: Bulk operations
  In order to control a lot of applications
  As a provider
  I want to make bulk operations

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And provider "foo.3scale.localhost" has "account_plans" switch visible


    Given these buyers signed up to provider "foo.3scale.localhost"
      | bob  |
      | jane |

    Given current domain is the admin domain of provider "foo.3scale.localhost"
    Given I am logged in as provider "foo.3scale.localhost"

  # FIXME: THREESCALE-7195 this scenario is failing in CircleCI. We need to refactor it as an integration test.
  Scenario: Show and hide bulk operations controls
    When I navigate to the accounts page
    When I check select for "bob"
    Then "Bulk operations" should be visible
      And I should see "Send email"
      And I should see "Change account plan"
      And I should see "Change state"
    When I uncheck select for "bob"
    Then "Bulk operations" should not be visible

  # FIXME: THREESCALE-7195 this scenario is failing in CircleCI. We need to refactor it as an integration test.
  @wip
  Scenario: Check all accounts with main checkbox
      And I am on the accounts admin page

    When I check select in table header

    Then all selects should be checked
      And "Bulk operations" should be visible

    When I uncheck select in table header
    Then none selects should be checked
      And "Bulk operations" should not be visible
