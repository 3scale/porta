Feature: Buyer side messages
  In order to facilitate communication between me and my provider
  As a buyer
  I want to have an internal messaging system at my disposal

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"
    When I log in as "bob" on foo.example.com

  Scenario: Sending a message
    Given account "bob" has no messages
    When I go to the dashboard
    And I follow "Messages"
    And I follow "Compose"
    Then I should see "To foo.example.com"
    When I fill in "Subject" with "Hello there"
    And I fill in "Body" with "Just wanted to say hi"
    And I press "Send"
    Then a message should be sent from buyer "bob" to provider "foo.example.com" with subject "Hello there" and body "Just wanted to say hi"
    When I follow "Sent Messages"
    Then I should see message to "foo.example.com" with subject "Hello there"
    When I follow "Hello there"
    Then I should see "Hello there"
    And I should see "Just wanted to say hi"

  Scenario: Receiving a message
    Given a message sent from provider "foo.example.com" to buyer "bob" with subject "How are you doing?" and body "Just checking if everything is allright"
    When I go to the dashboard
    And I follow "Messages"
    Then I should see unread message from "foo.example.com" with subject "How are you doing?"
    When I follow "How are you doing?"
    Then I should see "How are you doing?"
    And I should see "Just checking if everything is allright"
    When I follow "Inbox"
    Then I should see read message from "foo.example.com" with subject "How are you doing?"

  Scenario: Receiving a message without subject
    Given a message sent from provider "foo.example.com" to buyer "bob" with subject "" and body "Just checking if everything is allright"
    When I go to the dashboard
    And I follow "Messages"
    Then I should see unread message from "foo.example.com" with subject "Just checkin..."
    When I follow "Just checkin..."
    Then I should see "Just checking if everything is allright"
    When I follow "Inbox"
    Then I should see read message from "foo.example.com" with subject "Just checkin..."

  Scenario: Receiving a message without subject nor body
    Given a message sent from provider "foo.example.com" to buyer "bob" with subject "" and body ""
    When I go to the dashboard
    And I follow "Messages"
    Then I should see unread message from "foo.example.com" with subject "(no subject)"
    When I follow "(no subject)"
    When I follow "Inbox"
    Then I should see read message from "foo.example.com" with subject "(no subject)"

  Scenario: Repling to a message
    Given a message sent from provider "foo.example.com" to buyer "bob" with subject "Wassup?" and body "Everything OK?"

    When I go to the dashboard
    And I follow "Messages"
    When I follow "Wassup?"
    Then I should see "Wassup?"
    When I fill in "message_body" with "Yep, all good."
    And I press "Send reply"
    Then a message should be sent from buyer "bob" to provider "foo.example.com" with subject "Re: Wassup?" and body "Yep, all good."

  Scenario: Deleting a message
    Given a message sent from provider "foo.example.com" to buyer "bob" with subject "Wassup?" and body "Everything OK?"
    When I go to the dashboard
    And I follow "Messages"
    And follow "Delete message"
    Then I should not see a message from "foo.example.com" with subject "Wassup?"
    And the message from provider "foo.example.com" to buyer "bob" with subject "Wassup?" should be hidden
    When I follow "Trash"
    Then I should see a message from "foo.example.com" with subject "Wassup?"
    When I follow "Wassup?"
    Then I should see "Wassup?"
    And I should see "Everything OK?"

  Scenario: Restoring a deleted message
    Given a message sent from provider "foo.example.com" to buyer "bob" with subject "Wassup?" and body "Everything OK?"
    When I go to the dashboard
    And I follow "Messages"
    And I follow "Delete message"
    And I follow "Trash"
    And I press a button to restore the message from "foo.example.com" with subject "Wassup?"
    And I follow "Inbox"
    Then I should see a message from "foo.example.com" with subject "Wassup?"

  Scenario: Empting the trash
    Given a message sent from provider "foo.example.com" to buyer "bob" with subject "Hello" and body "Some stuff"
    When I go to the dashboard
    And I follow "Messages"
    And I follow "Delete message"
    And I follow "Trash"
    And I press "Empty the trash"
    Then I should not see a message from "foo.example.com" with subject "Hello"
    And there should be no message from provider "foo.example.com" to buyer "bob" with subject "Hello"
    And I should not see button "Empty the trash"
