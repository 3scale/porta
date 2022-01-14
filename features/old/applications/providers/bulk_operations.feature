@javascript
Feature: Bulk operations
  In order to control a lot of applications
  As a provider
  I want to make bulk operations

  Background:
    Given a provider "foo.3scale.localhost"
    Given a default application plan "Basic" of provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And provider "foo.3scale.localhost" has "service_plans" switch allowed

    Given a following buyers with applications exists:
      | name | provider        | applications |
      | bob  | foo.3scale.localhost | BobApp       |
      | jane | foo.3scale.localhost | JaneApp      |

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I don't care about application keys

  # FIXME: THREESCALE-7195 this scenario is failing in CircleCI. We need to refactor it as an integration test.
  @wip
  Scenario: Show and hide bulk operations controls
    Given I am logged in as provider "foo.3scale.localhost"

    When I go to the applications admin page
    When I check select for "BobApp"
    Then "Bulk operations" should be visible
      And I should see "Send email"
      And I should see "Change application plan"
      And I should see "Change state"
    When I uncheck select for "BobApp"
    Then "Bulk operations" should not be visible

  # FIXME: THREESCALE-7195 this scenario is failing in CircleCI. We need to refactor it as an integration test.
  @wip
  Scenario: Check all applications with main checkbox
    Given I am logged in as provider "foo.3scale.localhost"
      And I am on the applications admin page

    When I check select in table header

    Then all selects should be checked
      And "Bulk operations" should be visible

    When I uncheck select in table header
    Then none selects should be checked
      And "Bulk operations" should not be visible
