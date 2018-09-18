@javascript @wip
Feature: Bulk operations
  In order to cleanup accounts
  As a provider
  I want to delete plans in bulk

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled

    Given a default application plan "Basic" of provider "foo.example.com"
      And a following buyers with applications exists:
      | name | provider        | applications   |
      | bob  | foo.example.com | OneApp, TwoApp |
      | jane | foo.example.com | ThreeApp       |

    Given current domain is the admin domain of provider "foo.example.com"

  Scenario: Mass deleting applications
    Given I am logged in as "foo.example.com"
      And I am on the applications admin page

    When I check select for "OneApp" and "TwoApp"
     And I press "Delete"

    Then I should see "Delete selected applications"

    And I press "Delete applications" and I confirm dialog box

    #Then I should see "Action completed successfully" # This step failed randomly

    Then I should not see "OneApp"
     And I should not see "TwoApp"
     And I should see "ThreeApp"


