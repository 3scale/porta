@javascript
Feature: Buyer Account Invitations

  TODO: update as part of THREESCALE-9876 in the same way as features/provider/admin/account/invitations.feature

  Background:
    Given the default product of provider "master" has name "Master API"
    And the following application plan:
      | Product    | Name    |
      | Master API | power1M |
    And a provider is logged in
    And the provider has "multiple_applications" visible
    And the provider has "multiple_users" switch allowed
    And a buyer "lol cats"

  Scenario: Upgrade notice when provider does not have switch
    Given provider "foo.3scale.localhost" has "multiple_users" switch denied
    When I navigate to the page of the partner "lol cats"
    And I follow "0 Invitations"
    Then I should see upgrade notice for "multiple_users"

  Scenario: Navigation to the invitations page of a partner
    When I navigate to the page of the partner "lol cats"
    And I follow "0 Invitations"
    Then I should see the invitations page of the partner "lol cats"

  @emails
  Scenario: Sending an invitation for a partner account
    When I navigate to the page of the invitations of the partner "lol cats"
    And I send an invitation to "new@lolcats.net"
    Then I should see "Invitation was successfully created and will be sent soon"
    And "new@lolcats.net" should receive an invitation to account "lol cats"

  @emails
  Scenario: Inviting an existing user is not allowed
    Given an user "mary" of account "lol cats"
    And user "mary" has email "mary@lolcats.com"
    When I send "mary@lolcats.com" an invitation to account "lol cats"
    Then I should see an error saying an user with that email already exists

  Scenario: Sent invitations show their state
    Given an invitation sent to "alice@lolcats.com" to join account "lol cats" was accepted
    And an invitation sent to "bob@lolcats.com" to join account "lol cats"
    When I navigate to the page of the invitations of the partner "lol cats"
    Then the table should contain an accepted invitation from "alice@lolcats.com"
    And the table should contain a pending invitation from "bob@lolcats.com"

  Scenario: Destroying invitations
    Given an invitation sent to "alice@lolcats.com" to join account "lol cats"
    When I navigate to the page of the invitations of the partner "lol cats"
    # And select action "Delete" of "alice@example.org"
    # And confirm the dialog
    And I press "Delete" for an invitation from account "lol cats" for "alice@lolcats.com"
    And confirm the dialog
    Then I should not see invitation for "alice@lolcats.com"

  Scenario: Resending invitations
    Given an invitation sent to "invited@lolcats.com" to join account "lol cats"
    And an invitation sent to "pending@lolcats.com" to join account "lol cats"
    When I navigate to the page of the invitations of the partner "lol cats"
    And I resend the invitation to "invited@lolcats.com"
    Then I should see "Invitation will be resent soon"
    And invitation from account "lol cats" should be resent to "invited@lolcats.com"
    And I should see the invitation for "invited@lolcats.com" on top of the list

  Scenario: Accepted invitations cannot be resent
    Given an invitation sent to "accepted@lolcats.com" to join account "lol cats" was accepted
    And an invitation sent to "pending@lolcats.com" to join account "lol cats"
    When I navigate to the page of the invitations of the partner "lol cats"
    Then I should be able to resend the invitation to "pending@lolcats.com"
    But I should not be able to resend the invitation to "accepted@lolcats.com"
