@emails
Feature: Invitations
  In order to allow more people to be users of my account
  As an account admin
  I want to invite them

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "multiple_users" switch allowed

  Scenario: When switch is denied as provider
    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "multiple_users" switch denied
    When I log in as provider "foo.3scale.localhost"
     And I go to the provider users page
    Then I should not see "Invite a New Team Member"

    When I want to go to the provider new invitation page
    Then I should get access denied

  Scenario: When switch is denied as buyer
    Given a buyer "apininja" signed up to provider "foo.3scale.localhost"
     And provider "foo.3scale.localhost" has "multiple_users" switch denied
    When I log in as "apininja" on foo.3scale.localhost
     And I follow "Settings"
     And I follow "Users"
    Then I should not see "Invite new user"

  Scenario: Sending an invitation as buyer
    Given a buyer "apininja" signed up to provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "multiple_users" switch visible
    When I log in as "apininja" on foo.3scale.localhost
    And I follow "Settings"
    And I follow "Users"
    And I follow "Invite new user"
    And I fill in "Send invitation to" with "alice@foo.3scale.localhost"
    And I press "Invite User"
    Then invitation from account "apininja" should be sent to "alice@foo.3scale.localhost"

  Scenario: Attempt to send invitation to an email of already existing user
    Given an user "alice" of account "foo.3scale.localhost"
    And user "alice" has email "alice@foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider new invitation page
    And I fill in "Send invitation to" with "alice@foo.3scale.localhost"
    And I press "Send"
    Then I should see error "has been taken by another user" for field "Send invitation to"
    And no invitation should be sent to "alice@foo.3scale.localhost"

  Scenario: Invitation to an email of already existing pending invitation
    Given an invitation from account "foo.3scale.localhost" sent to "alice@foo.3scale.localhost"
    And a clear email queue
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider new invitation page
    And I fill in "Send invitation to" with "alice@foo.3scale.localhost"
    And I press "Send"
    Then I should see "This invitation has already been sent."

  Scenario: Deleted user from invitation with changed email
    Given an invitation from account "foo.3scale.localhost" sent to "ubuntu@foo.3scale.localhost"
    When I follow the link to signup provider "foo.3scale.localhost" in the invitation sent to "ubuntu@foo.3scale.localhost"
    And I fill in the invitation signup with email "gentoo@foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider users page
    Then I should see "gentoo@foo.3scale.localhost"
    And I should not see "ubuntu@foo.3scale.localhost"
    Then I press "Delete" for user "gentoo@foo.3scale.localhost" and I confirm dialog box
    And I go to the provider sent invitations page
    Then I should not see "ubuntu@foo.3scale.localhost"

  # FIXME: alice.access_to_service_admin_sections? -> false so the test fails
  @javascript
  Scenario: Accepting an invitation
    Given an invitation from account "foo.3scale.localhost" sent to "alice@foo.3scale.localhost"
     And all the rolling updates features are off
     And current domain is the admin domain of provider "foo.3scale.localhost"
    When I follow the link to signup in the invitation sent to "alice@foo.3scale.localhost"
     And I fill in the invitation signup as "alice"
     And current domain is the admin domain of provider "foo.3scale.localhost"
    When I try to log in as provider "alice"
    Then I should be logged in as "alice"
     And follow "API"
     And I should see "Analytics"

  Scenario: Managing sent invitations
    Given the following invitations from account "foo.3scale.localhost" exist:
      | Email                 | State    |
      | alice@foo.3scale.localhost | pending  |
      | bob@foo.3scale.localhost   | accepted |
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider users page
    And I follow "Invitations"
    Then I should see "Invitations" in a header
    And I should see pending invitation for "alice@foo.3scale.localhost"
    And I should see accepted invitation for "bob@foo.3scale.localhost"

  Scenario: Deleting an invitation
    Given an invitation from account "foo.3scale.localhost" sent to "alice@foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider sent invitations page
    And I press "Delete" for an invitation from account "foo.3scale.localhost" for "alice@foo.3scale.localhost" and I confirm dialog box
    Then I should not see invitation for "alice@foo.3scale.localhost"

  Scenario: Managing sent invitations disabled when multiple_users switch denied
     Given provider "foo.3scale.localhost" has "multiple_users" switch denied
       And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider users page
    Then I should not see "Invitations"

  @security @allow-rescue
  Scenario: Only admins can send invitations
    Given an active user "alice" of account "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "alice"
    And I go to the provider new invitation page
    Then I should be denied the access
