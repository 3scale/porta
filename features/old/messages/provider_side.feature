@javascript
Feature: Provider side messages
  In order to facilitate communication between me and my buyers
  As a provider
  I want to have an internal messaging system at my disposal

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"

    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

  Scenario: Compose link on the messages dashboard
    When I go to the provider dashboard
    And I follow "0 Messages"
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
    Then I should see the flash message "Message was sent."
    And account "bob" should have 0 messages
    Then a message should be sent from provider "foo.3scale.localhost" to buyer "bob" with subject "Party tonite!" and body "You are invited to my party."
    When I go to the provider dashboard
    And I follow "0 Messages"
    And I follow "Sent messages"
    Then I should see message to "bob" with subject "Party tonite!"
    When I follow "Party tonite!"
    Then I should see "Party tonite!"
    And I should see "You are invited to my party."

  Scenario: Receiving a message
    Given a message sent from buyer "bob" to provider "foo.3scale.localhost" with subject "I want out!" and body "I hate this system, delete my account ASAP!"

    And I go to the provider dashboard
    And I follow "0 Messages"
    Then I should see unread message from "bob" with subject "I want out!"
    When I follow "I want out!"
    Then I should see "I want out!"
    And I should see "I hate this system, delete my account ASAP!"
    When I follow "Inbox"
    Then I should see read message from "bob" with subject "I want out!"
