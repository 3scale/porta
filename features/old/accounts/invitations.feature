@emails
Feature: Invitations
  In order to allow more people to be users of my account
  As an account admin
  I want to invite them

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "multiple_users" switch allowed

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
