Feature: Invitations on partner accounts for admins
  In order to allow provider account admins to administer their partner accounts
  As an admin I want to manage the invitations of users to the partner accounts

  Background:
    Given a provider "foo.example.com"
      And an application plan "power1M" of provider "master"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "multiple_users" switch allowed
      And provider "foo.example.com" has the following buyers:
        | Name     |
        | lol cats |

   And current domain is the admin domain of provider "foo.example.com"
   When I log in as provider "foo.example.com"

  Scenario: Upgrade notice when provider does not have switch
    Given provider "foo.example.com" has "multiple_users" switch denied
    When I navigate to the page of the partner "lol cats"
      And I follow "Invitations"
    Then I should see upgrade notice for "multiple_users"

  Scenario: Navigation to the invitations page of a partner
    When I navigate to the page of the partner "lol cats"
      And I follow "Invitations"
    Then I should see the invitations page of the partner "lol cats"

  @emails
  Scenario: Sending an invitation for a partner account
    When I navigate to the page of the invitations of the partner "lol cats"
      And I send an invitation to "new@lolcats.net"
    Then "new@lolcats.net" should receive an invitation to account "lol cats"

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
    Then I should see accepted invitation for "alice@lolcats.com"
      And I should see pending invitation for "bob@lolcats.com"


  Scenario: Destroying invitations
    Given an invitation sent to "alice@lolcats.com" to join account "lol cats"
    When I navigate to the page of the invitations of the partner "lol cats"
      And I delete the invitation for "alice@lolcats.com"
    Then I should not see invitation for "alice@lolcats.com"


  Scenario: Resending invitations
    Given an invitation sent to "invited@lolcats.com" to join account "lol cats"
      And an invitation sent to "pending@lolcats.com" to join account "lol cats"
    When I navigate to the page of the invitations of the partner "lol cats"
      And I resend the invitation to "invited@lolcats.com"
    Then invitation from account "lol cats" should be resent to "invited@lolcats.com"
      And I should see the invitation for "invited@lolcats.com" on top of the list


  Scenario: Accepted invitations cannot be resent
    Given an invitation sent to "accepted@lolcats.com" to join account "lol cats" was accepted
      And an invitation sent to "pending@lolcats.com" to join account "lol cats"
    When I navigate to the page of the invitations of the partner "lol cats"
    Then I should be able to resend the invitation to "pending@lolcats.com"
      But I should not be able to resend the invitation to "accepted@lolcats.com"
