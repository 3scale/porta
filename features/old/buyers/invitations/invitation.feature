@emails
Feature: Invitations
  In order to be able to invite users to the site
  An invitations system should exist

  Background:
      Given a provider "foo.example.com"
      And provider "foo.example.com" has default service and account plan
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "multiple_users" switch allowed
      And provider "foo.example.com" has the following buyers:
        | Name     |
        | lol cats |


  @javascript
  Scenario: Invitations sign up pages are accessible without being logged in
     And current domain is the admin domain of provider "foo.example.com"
    When current domain is the admin domain of provider "foo.example.com"
    Given an invitation sent to "bob@foo.example.com" to join account "foo.example.com"
    When I follow the link to signup in the invitation sent to "bob@foo.example.com"
    Then I should see the invitation sign up page

  @javascript
  Scenario: Invitations signup process (uses extra fields)
      And current domain is the admin domain of provider "foo.example.com"
    Given master provider has the following fields defined for "User":
      | name       |
      | first_name |
      | last_name  |
    Given an invitation sent to "bob@foo.example.com" to join account "foo.example.com"
    When I follow the link to signup in the invitation sent to "bob@foo.example.com"

    When I fill in "Username" with "bob"
    And I fill in "First name" with "bob"
    And I fill in "Last name" with "dole"
    And I fill in "Password" with "supersecret"
    And I fill in "Password confirmation" with "supersecret"
    And I press "Sign up"

    Then I should see "Thanks for signing up"


  Scenario: Invitations are valid only once
    Given the invitation sent to "alice@lolcats.com" to join account "lol cats" was accepted
      And the current domain is "foo.example.com"
    When I follow the link to signup in the invitation sent to "alice@lolcats.com"
    
    Then I should see "Invitation token has already been accepted."
