@javascript
Feature: Audience > Messages > Outbox

  Background:
    Given a provider is logged in
    And a buyer "Alice" of the provider

  Scenario: Navigation from Audience
    When they press "Dashboard"
    And follow "Audience"
    And press "Messages"
    And follow "Sent messages"
    Then the current page is the provider sent messages page

  Scenario: Navigation from Dashboard
    When they follow "0 Messages"
    And follow "Sent messages"
    Then the current page is the provider sent messages page

  Rule: Outbox is empty
    Background:
      Given the provider has no messages

    Scenario: Empty state
      When they go to the provider sent messages page
      Then should see "Nothing to see here"
      And should see link "Compose Message"

  Rule: Inbox is not empty
    Background:
      Given the provider has no messages
      But a message sent from the provider to buyer "Alice" with subject "Welcome" and body "Welcome Alice"
      And a message sent from the provider to buyer "Alice" with subject "Bananas" and body "Alice, you're bananas"

    Scenario: List of messages
      When they go to the provider sent messages page
      Then should not see "Nothing to see here"
      And the table should contain the following:
        | Subject | From  |
        | Welcome | Alice |
        | Bananas | Alice |

    Scenario: Reading a message
      Given they go to the provider sent messages page
      When follow "Welcome"
      Then the current page is the provider page of message with subject "Welcome Alice"

    Scenario: Bulk operations
      Given they go to the provider sent messages page
      When item "Welcome" is selected
      Then the following bulk operations are available:
        | Delete |
      But item "Welcome" is unselected
      And the bulk operations are not visible

    Scenario: Deleting messages in bulk
      Given a message sent from the provider to buyer "Alice" with subject "Deleteme" and body "Deleteme"
      And they go to the provider sent messages page
      When item "Deleteme" is selected
      And press "Delete" within the bulk operations
      And press "Delete" within the modal
      Then wait a moment
      And should see "Messages moved into the trash"
      And should not see "Deleteme"

    Scenario: Deleting a message
      Given a message sent from the provider to buyer "Alice" with subject "Deleteme" and body "Deleteme"
      When they go to the provider sent messages page
      And delete the message with subject "Deleteme"
      And should see "Message was deleted."
      And should not see "Deleteme"
