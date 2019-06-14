@javascript
Feature: Provider side messages
  In order to facilitate communication between me and my buyers
  As a provider
  I want to have an internal messaging system at my disposal

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"

    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

  Scenario: Compose link on the messages dashboard
    When I go to the provider dashboard
    And I follow "Messages"
    Then I should see link "Compose Message"

  Scenario: Sending a message
    Given account "bob" has no messages

    And I go to the provider dashboard
    And I navigate to the accounts page
    And I follow "bob"
    And I follow "Send message"
    Then the "To" field should be fixed to "bob"
    When I fill in "Subject" with "Party tonite!"
    And I fill in "Body" with "You are invited to my party."
    And I press "Send"
    Then I should see "Message was sent"
    And account "bob" should have 0 messages
    Then a message should be sent from provider "foo.example.com" to buyer "bob" with subject "Party tonite!" and body "You are invited to my party."
    When I follow "Dashboard"
    And I follow "Messages"
    And I follow "Sent messages"
    Then I should see message to "bob" with subject "Party tonite!"
    When I follow "Party tonite!"
    Then I should see "Party tonite!"
    And I should see "You are invited to my party."

  Scenario: Receiving a message
    Given a message sent from buyer "bob" to provider "foo.example.com" with subject "I want out!" and body "I hate this system, delete my account ASAP!"

    And I go to the provider dashboard
    And I follow "Messages"
    Then I should see unread message from "bob" with subject "I want out!"
    When I follow "I want out!"
    Then I should see "I want out!"
    And I should see "I hate this system, delete my account ASAP!"
    When I follow "Inbox"
    Then I should see read message from "bob" with subject "I want out!"

  Scenario: Bulk operations
    Given account "foo.example.com" has no messages
    And 40 messages sent from buyer "bob" to provider "foo.example.com" with subject "Wildness" and body "On the road."

    And I go to the provider dashboard
    And I follow "Messages"

    When I check the first select in table body
    Then "Bulk operations" should be visible
      And I should see "Delete selected emails"
      And "(select all 40 messages)" should not be visible
    When I uncheck the first select in table body
    Then "Bulk operations" should not be visible

    When I check select in table header

    Then all selects should be checked
      And "Bulk operations" should be visible

    When I uncheck select in table header
    Then none selects should be checked
      And "Bulk operations" should not be visible

    When I check select in table header
      Then I should see "(select all 40 messages)"
    And I follow "(select all 40 messages)"
      Then I should see "(only select the 30 messages on this page)"
    And I follow "(only select the 30 messages on this page)"
      Then I should see "(select all 40 messages)"
    When I uncheck the first select in table body
      Then "(select all 40 messages)" should not be visible

  Scenario: Availability of select all messages action
    Given account "foo.example.com" has no messages

    And 20 messages sent from buyer "bob" to provider "foo.example.com" with subject "Wildness" and body "On the road."

    And I go to the provider dashboard
    And I follow "Messages"

    When I check select in table header
      Then I should not see "(select all 20 messages)"

    And 20 messages sent from buyer "bob" to provider "foo.example.com" with subject "Wildness" and body "On the road."

    And I go to the provider dashboard
    And I follow "Messages"

    When I check select in table header
      Then I should see "(select all 40 messages)"

  Scenario: Deleting a message with bulk operations
    Given a message sent from buyer "bob" to provider "foo.example.com" with subject "Wildness" and body "Into the wild!"
    Given a message sent from buyer "bob" to provider "foo.example.com" with subject "Alaska" and body "Into the wild!"

    And I go to the provider dashboard
    And I follow "Messages"
      Then I should see "Wildness"
      Then I should see "Alaska"

    When I check select for "Wildness"
    And I press "Delete" within "#bulk-operations"
      Then I should see "It will move all your selected messages to the trash."

    When I press "Delete" within "#colorbox"
      Then I should see "Action completed successfully"
      And I should not see "Wildness"
      And I should see "Alaska"

  Scenario: Deleting all messages with bulk operations
    Given account "foo.example.com" has no messages

    And 40 messages sent from buyer "bob" to provider "foo.example.com" with subject "Wildness" and body "On the road."

    When I go to the provider dashboard
    And I follow "Messages"
      Then I should see "Wildness"
      And should not see "You have no messages."

    When I check select in table header
    And I follow "(select all 40 messages)"
      Then I should not see "(select all 40 messages)"
    When I press "Delete" within "#bulk-operations"
      Then I should see "It will move all your selected messages to the trash."

    When I press "Delete" within "#colorbox"
      Then I should see "Action completed successfully"
      And I should not see "Wildness"
      And should see "You have no messages."
