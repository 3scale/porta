@javascript
Feature: Messages inbox

  Background:
    Given a provider is logged in
    And a buyer "Alice" of the provider

  Scenario: Navigation
    When they press "Dashboard"
    And they follow "Audience"
    And they press "Messages"
    And they follow "Inbox"
    Then the current page is the provider inbox page

  Rule: Inbox is empty
    Scenario: Empty state
      When they go to the provider inbox page
      And should see "You have no messages."

  Rule: Inbox is not empty
    Background:
      Given 40 messages sent from buyer "Alice" to provider "foo.3scale.localhost" with subject "Wildness" and body "On the road."

    Scenario: List of messages
      When they go to the provider inbox page
      Then should not see "You have no messages."

    Scenario: Bulk operations
      Given they go to the provider inbox page
      When item "Wildness" is selected
      Then the following bulk operations are available:
        | Delete |
      But item "Wildness" is unselected
      And the bulk operations are not visible

    Scenario: Select all messages in all pages
      Given they go to the provider inbox page
      And they select all items in the table
      Then should see "30 messages selected (select all 40 messages)"
      And follow "(select all 40 messages)"
      And should see "40 messages selected (only select the 30 messages on this page)"
      But follow "(only select the 30 messages on this page)"
      And should see "30 messages selected (select all 40 messages)"

    Scenario: Delete a single message in bulk
      Given 1 messages sent from buyer "Alice" to provider "foo.3scale.localhost" with subject "Deleteme" and body "On the road."
      And they go to the provider inbox page
      When item "Deleteme" is selected
      And press "Delete" within the bulk operations
      And press "Delete" within the modal
      Then wait a moment
      And should see "Messages moved into the trash"
      And should not see "Deleteme"

    Scenario: Delete all messages in current page
      Given they go to the provider inbox page
      When they select all items in the table
      And press "Delete" within the bulk operations
      And press "Delete" within the modal
      Then wait a moment
      And should see "Messages moved into the trash"
      And they select all items in the table
      And should see "10 messages selected"

    Scenario: Delete all messages in all pages
      Given they go to the provider inbox page
      When they select all items in the table
      And follow "(select all 40 messages)"
      And press "Delete" within the bulk operations
      And press "Delete" within the modal
      Then wait a moment
      And should see "Messages moved into the trash"
      And should see "You have no messages"
