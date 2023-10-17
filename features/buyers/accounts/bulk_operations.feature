@javascript
Feature: Buyer accounts bulk operations

  Background:
    Given a provider is logged in

  Rule: Single account plan
    Background:
      Given a buyer "Alice" of the provider

    Scenario: Bulk operations does not include "Change account plan"
      Given the provider has "account_plans" switch allowed
      And they go to the buyer accounts page
      When item "Alice" is selected
      Then the following bulk operations are available:
        | Send email   |
        | Change state |

  Rule: Multiple account plans
    Background:
      Given the provider has the following buyers:
        | Name          | State    | Plan    |
        | Alice         | approved | Default |
        | Bob           | approved | Awesome |
        | Bad buyer     | rejected | Default |
        | Pending buyer | pending  | Tricky  |
      And admin of account "Alice" has email "alice@example.com"
      And admin of account "Bob" has email "bob@example.com"

    Scenario: Available bulk operations when Account Plans are disabled
      Given the provider has "account_plans" switch denied
      And they go to the buyer accounts page
      When item "Alice" is selected
      Then the following bulk operations are available:
        | Send email   |
        | Change state |

    Scenario: Available bulk operations when Account Plans are enabled
      Given the provider has "account_plans" switch allowed
      And they go to the buyer accounts page
      When item "Alice" is selected
      Then the following bulk operations are available:
        | Send email          |
        | Change account plan |
        | Change state        |

    Scenario: Bulk operations card shows when an items are selected
      Given they go to the buyer accounts page
      When item "Alice" is selected
      And item "Bob" is selected
      Then the bulk operations are visible
      And should see "You have selected 2 accounts and you can make following operations with them:"
      But item "Alice" is unselected
      And item "Bob" is unselected
      Then the bulk operations are not visible

    Scenario: Select all items in the table
      Given they go to the buyer accounts page
      And they select all items in the table
      Then the bulk operations are visible
      When they unselect all items in the table
      Then the bulk operations are not visible

    Scenario: Send an email without subject
      Given they go to the buyer accounts page
      When item "Alice" is selected
      And press "Send email"
      And fill in "Subject" with ""
      And fill in "Body" with "This is the body"
      And press "Send"
      Then "alice@example.com" should receive no emails

    Scenario: Send an email without body
      Given they go to the buyer accounts page
      When item "Alice" is selected
      And press "Send email"
      And fill in "Subject" with "This is a subject"
      And fill in "Body" with ""
      And press "Send"
      Then "alice@example.com" should receive no emails

    Scenario: Send email in bulk
      Given they go to the buyer accounts page
      And "alice@example.com" should receive no emails
      And "bob@example.com" should receive no emails
      When item "Alice" is selected
      And item "Bob" is selected
      And press "Send email"
      And fill in "Subject" with "This is the subject"
      And fill in "Body" with "This is the body"
      And press "Send" and I confirm dialog box
      Then I should see "Successfully sent 2 emails."
      Then "alice@example.com" should receive 1 email
      Then "bob@example.com" should receive 1 email

    Scenario: Change account plan in bulk
      Given the provider has "account_plans" switch allowed
      And they go to the buyer accounts page
      And the table should contain the following:
        | Group/Org.    | Plan    |
        | Pending buyer | Tricky  |
        | Bad buyer     | Default |
        | Bob           | Awesome |
        | Alice         | Default |
      When item "Alice" is selected
      And item "Bob" is selected
      And press "Change account plan"
      And select "Awesome" from "Plan"
      And press "Change plan" and I confirm dialog box
      Then should see "Successfully changed the plan of 2 accounts"
      And the table should contain the following:
        | Group/Org.    | Plan    |
        | Pending buyer | Tricky  |
        | Bad buyer     | Default |
        | Bob           | Awesome |
        | Alice         | Awesome |

    Scenario: Change state in bulk
      Given they go to the buyer accounts page
      And the table should contain the following:
        | Group/Org.    | State    |
        | Pending buyer | Pending  |
        | Bad buyer     | Rejected |
        | Bob           | Approved |
        | Alice         | Approved |
      When item "Alice" is selected
      And item "Bob" is selected
      And press "Change state"
      And select "Make pending" from "Action"
      And press "Change state" and I confirm dialog box within the modal
      Then should see "Successfully changed the state of 2 accounts"
      And the table should contain the following:
        | Group/Org.    | State    |
        | Alice         | Pending  |
        | Bob           | Pending  |
        | Bad buyer     | Rejected |
        | Pending buyer | Pending  |

    Scenario: Sending email throws an error
      Given the email will fail when sent
      And they go to the buyer accounts page
      When item "Alice" is selected
      And press "Send email"
      And fill in "Subject" with "Error"
      And fill in "Body" with "This will fail"
      And press "Send" and I confirm dialog box
      Then the bulk operation has failed for "Alice"
      And "alice@example.com" should receive no emails

    Scenario: Changing account plan throws an error
      Given the provider has "account_plans" switch allowed
      And the account will return an error when changing its plan
      And they go to the buyer accounts page
      When item "Alice" is selected
      And press "Change account plan"
      And select "Awesome" from "Plan"
      And press "Change plan" and I confirm dialog box
      Then the bulk operation has failed for "Alice"

    Scenario: Changing state throws an error
      Given the account will return an error when approved
      And they go to the buyer accounts page
      And item "Pending buyer" is selected
      And press "Change state"
      When select "Approve" from "Action"
      And press "Change state" and I confirm dialog box within the modal
      Then the bulk operation has failed for "Pending buyer"

    Scenario: Rejecting buyer accounts in bulk
      Given they go to the buyer accounts page
      And the table should contain the following:
        | Group/Org.    | State    |
        | Pending buyer | Pending  |
        | Bad buyer     | Rejected |
        | Bob           | Approved |
        | Alice         | Approved |
      When item "Pending buyer" is selected
      And item "Bad buyer" is selected
      And item "Bob" is selected
      And item "Alice" is selected
      And press "Change state"
      And select "Reject" from "Action"
      And press "Change state" and I confirm dialog box within the modal
      Then should see "Successfully changed the state of 4 accounts"
      And the table should contain the following:
        | Group/Org.    | State    |
        | Alice         | Rejected |
        | Bob           | Rejected |
        | Bad buyer     | Rejected |
        | Pending buyer | Rejected |
