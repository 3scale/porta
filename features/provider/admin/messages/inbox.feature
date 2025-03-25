@javascript
Feature: Audience > Messages > Inbox

  Background:
    Given a provider is logged in
    And a buyer "Alice"

  Scenario: Navigation from Audience
    When they press "Dashboard"
    And they follow "Audience"
    And they press "Messages"
    And they follow "Inbox"
    Then the current page is the provider inbox page

  Scenario: Navigation from Dashboard
    When they follow "0 Messages"
    Then the current page is the provider inbox page

  Rule: Inbox is empty
    Scenario: Empty state
      When they go to the provider inbox page
      Then should see "Nothing to see here"

  Rule: Inbox is not empty
    Background:
      Given 30 messages sent from buyer "Alice" to the provider with subject "Oh, no!" and body "Pepe is in da house"

    Scenario: List of messages
      When they go to the provider inbox page
      Then should not see "Nothing to see here"

    Scenario: Reading an unread message
      Given they go to the provider inbox page
      And they should see unread message from "Alice" with subject "Oh, no!"
      When follow any "Oh, no!"
      And should see "Send reply"
      And follow "Inbox"
      Then they should see read message from "Alice" with subject "Oh, no!"

    Scenario: Bulk operations
      Given they go to the provider inbox page
      When item "Oh, no!" is selected
      Then the following bulk operations are available:
        | Delete |
      But item "Oh, no!" is unselected
      And they should not be able to see the bulk operations

    Scenario: Select all messages in all pages
      Given they go to the provider inbox page
      And they select all items in the table
      Then should see "30 selected" within the toolbar

    Scenario: Delete a single message in bulk
      Given 1 messages sent from buyer "Alice" to provider "foo.3scale.localhost" with subject "Deleteme" and body "On the road."
      And they go to the provider inbox page
      When item "Deleteme" is selected
      And select bulk action "Delete"
      And press "Delete" within the modal
      Then wait a moment
      And should see "Messages moved into the trash"
      And should not see "Deleteme"

    Scenario: Delete all messages in current page
      Given they go to the provider inbox page
      When they select all items in the current page
      And select bulk action "Delete"
      And press "Delete" within the modal
      Then wait a moment
      And should see "Messages moved into the trash"
      And they select all items in the current page
      And should see "10 selected" within the toolbar

    Scenario: Delete all messages in all pages
      Given they go to the provider inbox page
      When they select all items in the table
      And select bulk action "Delete"
      And press "Delete" within the modal
      Then wait a moment
      And should see "Messages moved into the trash"
      And should see "Nothing to see here"
