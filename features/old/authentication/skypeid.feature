@wip
Feature: SkypeID
  In order to use the 3scale product
  As an user with SkypeID
  I want to use it to sign in

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has the following settings:
      | signup workflow         | without_plans |
      | authentication strategy | skypeid       |
    And provider "master" has the following settings:
      | authentication strategy | skypeid       |

  Scenario: Sign in with SkypeID page
    Given a buyer "bob" signed up to provider "foo.example.com"
    When I go to foo.example.com
    Then I should see the SkypeID login button
    And the redirection to SkypeID should force english as language

  Scenario: Successful buyer sign in
    Given a buyer "bob" signed up to provider "foo.example.com"
    When I successfully sign in as "bob" on foo.example.com using SkypeID
    Then I should be logged in as user "bob"
    And I should be on the homepage

  Scenario: Successful provider sign in on buyer domain
    When I successfully sign in as "foo.example.com" on foo.example.com using SkypeID
    Then I should be logged in as user "foo.example.com"
    And the current domain should be foo.example.com
    And I should be on the homepage

  Scenario: Successful provider sign in on provider domain
    When I successfully sign in as "foo.example.com" on the master domain using SkypeID
    Then I should be logged in as user "foo.example.com"
    And the current domain should be the master domain
    And I should be on the provider dashboard page

  @security
  Scenario: Sign in attempt with skype name not registered in the system on buyer domain
    Given there is no user with username "bob"
    When I successfully sign in as "bob" on foo.example.com using SkypeID
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"
  
  @security
  Scenario: Sign in attempt with skype name not registered in the system on provider domain
    Given there is no user with username "bob"
    When I successfully sign in as "bob" on the master domain using SkypeID
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"

  @security
  Scenario: Sign in attempt of unactivated and unapproved buyer user
    Given an unactivated and unapproved buyer "bob" signed up to provider "foo.example.com"
    When I successfully sign in as "bob" on foo.example.com using SkypeID
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"

  @security
  Scenario: Sign in attempt of activated but unapproved buyer user
    Given an activated but unapproved buyer "bob" signed up to provider "foo.example.com"
    When I successfully sign in as "bob" on foo.example.com using SkypeID
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"

  @security
  Scenario: Sign in attempt of approved but unactivated buyer user
    Given an approved but unactivated buyer "bob" signed up to provider "foo.example.com"
    When I successfully sign in as "bob" on foo.example.com using SkypeID
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"

  @security
  Scenario: Sign in attempt of rejected buyer user
    Given a rejected buyer "bob" signed up to provider "foo.example.com"
    When I successfully sign in as "bob" on foo.example.com using SkypeID
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"

  @security
  Scenario: Sign in attempt with invalid response from the SkypeID server on buyer domain
    Given a buyer "bob" signed up to provider "foo.example.com"
    When I attempt to forge the SkypeID response as "bob" on foo.example.com
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"
  
  @security
  Scenario: Sign in attempt with invalid response from the SkypeID server on provider domain
    When I attempt to forge the SkypeID response as "foo.example.com" on the master domain
    Then I should not be logged in
    And I should see "Your Skype Name is not authorized for access"

  @security
  Scenario: Remember last login information on successful login
    Given a buyer "bob" signed up to provider "foo.example.com"
    And my remote address is 1.2.3.4
    And the time is 30th June 2001, 12:23
    When I successfully sign in as "bob" on foo.example.com using SkypeID
    Then user "bob" should have last login on 30th June 2001 at 12:23 from 1.2.3.4

