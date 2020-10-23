@wip
Feature: Invitations to provider users
  In order to allow more people to be users of my account
  As an account admin I want to invite them

  Background:
    Given a provider "foo.3scale.localhost"
      And an invitation from account "foo.3scale.localhost" sent to "bar@bar.it"
      And current domain is the admin domain of provider "foo.3scale.localhost"
     When I log in as provider "foo.3scale.localhost"

  Scenario: Resending invitations
    When I navigate to the sent invitations page
    Then I should see buttons to resend the invitations

    When I resend the invitation to "bar@bar.it"
    Then invitation from "foo.3scale.localhost" should be resent to "bar@bar.it"
      And invitation from account "foo.3scale.localhost" should be resent to "bar@bar.it"
      And I should see the invitation for "bar@bar.it" on top of the list


  Scenario: Accepted invitations cannot be resent
    Given invitation from "foo.3scale.localhost" sent to "alice@foo.3scale.localhost" was accepted
    When I visit the sent invitations page

    Then I should see the button to resend the invitation to "bob@foo.3scale.localhost"
      But I should not see the button to resend the invitation to "alice@foo.3scale.localhost"
