@emails
Feature: Invitations
  In order to allow more people to be users of my account
  As an account admin
  I want to invite them

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "multiple_users" switch allowed

  Scenario: When switch is denied as provider
    Given current domain is the admin domain of provider "foo.example.com"
      And provider "foo.example.com" has "multiple_users" switch denied
    When I log in as provider "foo.example.com"
     And I follow "Account"
     And I follow "Users"
    Then I should not see "Invite a New Team Member"

    When I want to go to the provider new invitation page
    Then I should get access denied

  Scenario: When switch is denied as buyer
    Given a buyer "apininja" signed up to provider "foo.example.com"
     And provider "foo.example.com" has "multiple_users" switch denied
    When I log in as "apininja" on foo.example.com
     And I follow "Settings"
     And I follow "Users"
    Then I should not see "Invite new user"

  Scenario: Sending an invitation as buyer
    Given a buyer "apininja" signed up to provider "foo.example.com"
      And provider "foo.example.com" has "multiple_users" switch visible
    When I log in as "apininja" on foo.example.com
    And I follow "Settings"
    And I follow "Users"
    And I follow "Invite new user"
    And I fill in "Send invitation to" with "alice@foo.example.com"
    And I press "Invite User"
    Then invitation from account "apininja" should be sent to "alice@foo.example.com"

  Scenario: Attempt to send invitation to an email of already existing user
    Given an user "alice" of account "foo.example.com"
    And user "alice" has email "alice@foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider new invitation page
    And I fill in "Send invitation to" with "alice@foo.example.com"
    And I press "Send"
    Then I should see error "has been taken by another user" for field "Send invitation to"
    And no invitation should be sent to "alice@foo.example.com"

  Scenario: Invitation to an email of already existing pending invitation
    Given an invitation from account "foo.example.com" sent to "alice@foo.example.com"
    And a clear email queue
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider new invitation page
    And I fill in "Send invitation to" with "alice@foo.example.com"
    And I press "Send"
    Then I should see "This invitation has already been sent."

  @javascript
  Scenario: Deleted user from invitation with changed email
    Given an invitation from account "foo.example.com" sent to "ubuntu@foo.example.com"
    When I follow the link to signup provider "foo.example.com" in the invitation sent to "ubuntu@foo.example.com"
    And I fill in the invitation signup with email "gentoo@foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    Then I should see "gentoo@foo.example.com"
    And I should not see "ubuntu@foo.example.com"
    Then I press "Delete" for user "gentoo@foo.example.com" and I confirm dialog box
    And I follow "Invitations"
    Then I should not see "ubuntu@foo.example.com"

  Scenario: Accepting an invitation
    Given an invitation from account "foo.example.com" sent to "alice@foo.example.com"
     And all the rolling updates features are off
    When I follow the link to signup in the invitation sent to "alice@foo.example.com"
      And I fill in the invitation signup as "alice"

     And current domain is the admin domain of provider "foo.example.com"
    When I try to log in as provider "alice"
    Then I should be logged in as "alice"
    And I should see "Analytics"
    And follow "Analytics"
    And I should see "Analytics"

  Scenario: Managing sent invitations
    Given the following invitations from account "foo.example.com" exist:
      | Email                 | State    |
      | alice@foo.example.com | pending  |
      | bob@foo.example.com   | accepted |
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    And I follow "Invitations"
    Then I should see "Sent Invitations" in a header
    And I should see pending invitation for "alice@foo.example.com"
    And I should see accepted invitation for "bob@foo.example.com"

  Scenario: Deleting an invitation
    Given an invitation from account "foo.example.com" sent to "alice@foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider sent invitations page
    And I press "Delete" for an invitation from account "foo.example.com" for "alice@foo.example.com"
    Then I should not see invitation for "alice@foo.example.com"

  Scenario: Managing sent invitations disabled when multiple_users switch denied
     Given provider "foo.example.com" has "multiple_users" switch denied
       And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    Then I should not see "Invitations"

  @security @allow-rescue
  Scenario: Only admins can send invitations
    Given an active user "alice" of account "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "alice"
    And I go to the provider new invitation page
    Then I should be denied the access
