Feature: Groups switch
  The value of the groups switch
  Controls the Groups and Sections access restricting feature

  Background:
    Given a provider "foo.example.com"
      And an application plan "power1M" of provider "master"
      And provider "foo.example.com" has multiple applications enabled
    Given provider "foo.example.com" has Browser CMS activated
      And current domain is the admin domain of provider "foo.example.com"

  Scenario: Groups not accessible if not enabled
    Given provider "foo.example.com" has "groups" switch denied
    When I log in as provider "foo.example.com"
   When I want to go to the groups page
   Then I should get access denied

  Scenario: Groups tab works if enabled
    Given provider "foo.example.com" has "groups" switch allowed
    When I log in as provider "foo.example.com"
     And I go to the groups page
    Then I should be on the groups page

  Scenario: Buyer groups do not show if groups is disabled
    Given a buyer "buyer" signed up to provider "foo.example.com"
    Given provider "foo.example.com" has "groups" switch denied
    When I log in as provider "foo.example.com"
      And I go to the buyer account page for "buyer"
    Then I should not see link to the buyer account "buyer" groups page

  Scenario: Members groups do not show if groups is disabled
    Given an user "member" of account "foo.example.com"
    Given provider "foo.example.com" has "groups" switch denied
    When I log in as provider "foo.example.com"
      And I go to the provider user edit page for "member"
    Then I should not see link to the new CMS groups page

  Scenario: Finance permission for providers does not show if finance switch is denied
    Given the default set of permissions is created
    Given provider "foo.example.com" has "groups" switch allowed
      And provider "foo.example.com" has "finance" switch denied
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    When I go to the new CMS groups page
    Then finance should not show in the permissions list

    @wip
  Scenario: Finance permission for providers shows if finance switch is enabled
    Given the default set of permissions is created
    Given provider "foo.example.com" has "groups" switch allowed
      And provider "foo.example.com" has "finance" switch allowed
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    When I go to the new CMS groups page
    Then finance should show in the permissions list
