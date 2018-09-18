@javascript
Feature: Bulk operations
  In order to approve or reject accounts quickly
  As a provider
  I want to change account states in bulk

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled

    Given a buyer "approved" signed up to provider "foo.example.com"
    Given a pending buyer "pending" signed up to provider "foo.example.com"
    Given a rejected buyer "rejected" signed up to provider "foo.example.com"
      And I don't care about application keys

    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"

  Scenario: Approve accounts
      And I am on the accounts admin page
    When I follow "Group/Org."
     And I check select for "pending" and "rejected"
     And I press "Change state"

    Then I should see "Approve, reject or make pending selected accounts"

    When I select "Approve" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    Then I should see following table:
      | Group/Org. ▲ | State   |
      | approved     | Approved |
      | pending      | Approved |
      | rejected     | Approved |

  Scenario: Reject accounts
     And I am on the accounts admin page
    When I follow "Group/Org."
     And I check select for "approved" and "pending"
     And I press "Change state"

    Then I should see "Approve, reject or make pending selected accounts"

    When I select "Reject" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    Then I should see following table:
      | Group/Org. ▲ | State   |
      | approved     | Rejected |
      | pending      | Rejected |
      | rejected     | Rejected |

  Scenario: Make pending
     And I am on the accounts admin page
    When I follow "Group/Org."
     And I check select for "approved", "pending" and "rejected"
     And I press "Change state"

    Then I should see "Approve, reject or make pending selected accounts"

    When I select "Make pending" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    Then I should see following table:
      | Group/Org. ▲ | State  |
      | approved     | Pending |
      | pending      | Pending |
      | rejected     | Pending |


