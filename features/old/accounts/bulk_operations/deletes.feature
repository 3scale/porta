@javascript @wip
Feature: Bulk operations
  In order to cleanup accounts
  As a provider
  I want to delete plans in bulk

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled

      Given these buyers signed up to provider "foo.3scale.localhost"
      | bob  |
      | jane |
      | mike |

    Given current domain is the admin domain of provider "foo.3scale.localhost"

  Scenario: Mass change of account plans
    Given an application plan "Advanced" of provider "foo.3scale.localhost"
      And I am logged in as "foo.3scale.localhost"
      And I am on the accounts admin page

    When I check select for "bob" and "mike"
     And I press "Delete"

    Then I should see "Delete selected accounts"

    And I press "Delete accounts" and I confirm dialog box

    Then I should see "Action completed successfully"
     And I should not see "bob"
     And I should not see "mike"
     And I should see "jane"


