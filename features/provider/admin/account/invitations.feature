@javascript
Feature: Provider Account Settings User Invitations

  Background:
    Given a provider is logged in

  Rule: User is a member
    Background:
      Given a member user "alice" of the provider
      And the user logs in

    Scenario: Inviting new users is not allowed
      When they go to the provider users page
      Then there should not be a link to "Invite a New User"
      And they should see an error when going to the provider new invitation page

    Scenario: Navigation to invitations page is not possible
      When they select "Account Settings" from the context selector
      Then they should not see "Users" within the main menu

    @security @allow-rescue
    Scenario: Only admins can send invitations
      When they go to the provider new invitation page
      Then I should be denied the access

  Rule: No multiple users permissions
    Background:
      Given the provider has "multiple_users" switch denied

    Scenario: Inviting new users is not allowed
      When they go to the provider users page
      Then there should not be a link to "Invite a New User"
      And they should see an error when going to the provider new invitation page

    Scenario: Navigation to invitations page is not possible
      When they select "Account Settings" from the context selector
      And press "Users" within the main menu
      And they should not see "Invitations" within the main menu's section Users

    @security @allow-rescue
    Scenario: Only admins can send invitations
      When they go to the provider new invitation page
      Then I should be denied the access

  Rule: Multiple users permission
    Background:
      Given the provider has "multiple_users" switch allowed

    Scenario: Navigation
      When they select "Account Settings" from the context selector
      And press "Users" within the main menu
      And follow "Invitations" within the main menu's section Users
      Then the current page is the provider sent invitations page

    Scenario: Inviting new users is possible
      When they go to the provider users page
      And follow "Invite a new user"
      Then the current page is the provider new invitation page

    Scenario: Inviting an existing user
      Given a member user "Alice" of the provider
      And the user has email "alice@example.org"
      When they go to the provider sent invitations page
      And follow "Invite a new team member"
      And the form is submitted with:
        | Send invitation to | alice@example.org |
      Then field "Send invitation to" has inline error "Has been taken by another user"
      And no invitation should be sent to "alice@example.org"

    Scenario: Inviting the same user twice
      Given an invitation sent to "alice@example.org" to join account "foo.3scale.localhost"
      And a clear email queue
      When they go to the provider new invitation page
      And the form is submitted with:
        | Send invitation to | alice@example.org |
      Then field "Send invitation to" has inline error "This invitation has already been sent."
      And no invitation should be sent to "alice@example.org"

    Scenario: Accepting an invitation with different email
      Given an invitation sent to "alice@example.org" to join account "foo.3scale.localhost"
      And the invitee follows the link to sign up to the provider in the invitation sent to "alice@example.org"
      And the form is submitted with:
        | Email                 | peter@example.com |
        | Username              | peter             |
        | Password              | superSecret1234#  |
        | Password confirmation | superSecret1234#  |
      And they log out
      When the provider logs in
      And they go to the provider users page
      Then the table has the following row:
        | Name  | Email             | Role   |
        | peter | peter@example.com | member |

    Scenario: List of invitations
      Given the following invitations from the provider:
        | Email             | State    |
        | alice@example.org | pending  |
        | bob@example.org   | accepted |
      When they go to the provider sent invitations page
      Then the table should contain a pending invitation from "alice@example.org"
      And the table should contain an accepted invitation from "bob@example.org"

    Scenario: Deleting an invitation
      Given an invitation sent to "alice@example.org" to join account "foo.3scale.localhost"
      When they go to the provider sent invitations page
      And select action "Delete" of "alice@example.org"
      And confirm the dialog
      Then they should see a toast alert with text "Invitation was successfully deleted"
      And they should see "No invitations"
