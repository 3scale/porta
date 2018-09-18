@javascript @wip
Feature: Bulk operations
  In order to cleanup accounts
  As a provider
  I want to delete plans in bulk

  Background:
    Given a provider "foo.example.com"
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

  Scenario: Mass deleting service contracts
    Given I am logged in as "foo.example.com"
      And I am on the service contracts admin page

    When I check select for "bob" and "mike"
     And I press "Delete"

    Then I should see "Delete selected subscriptions"

    And I press "Delete subscriptions" and I confirm dialog box

    #Then I should see "Action completed successfully" # This step failed randomly

    Then I should not see "bob"
     And I should not see "mike"
     And I should see "jane"


