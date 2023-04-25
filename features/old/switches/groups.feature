@javascript
Feature: Groups switch
  The value of the groups switch
  Controls the Groups and Sections access restricting feature

  Background:
    Given a provider is logged in
    And an application plan "power1M" of provider "master"
    And the provider has multiple applications enabled
    Given provider "foo.3scale.localhost" has Browser CMS activated

  Scenario: Groups not accessible if not enabled
    Given the provider has "groups" switch denied
    When I want to go to the groups page
    Then I should get access denied

  Scenario: Groups tab works if enabled
    Given the provider has "groups" switch allowed
    And I go to the groups page
    Then I should be on the groups page

  Scenario: Buyer groups do not show if groups is disabled
    Given a buyer "buyer" signed up to provider "foo.3scale.localhost"
    Given the provider has "groups" switch denied
    And I go to the buyer account page for "buyer"
    Then I should not see link to the buyer account "buyer" groups page

  Scenario: Members groups do not show if groups is disabled
    Given an user "member" of account "foo.3scale.localhost"
    Given the provider has "groups" switch denied
    And I go to the provider user edit page for "member"
    Then I should not see link to the new CMS groups page

  Scenario: Finance permission for providers does not show if finance switch is denied
    Given the default set of permissions is created
    Given the provider has "groups" switch allowed
    And the provider has "finance" switch denied
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    When I go to the new CMS groups page
    Then finance should not show in the permissions list

  @wip
  Scenario: Finance permission for providers shows if finance switch is enabled
    Given the default set of permissions is created
    Given the provider has "groups" switch allowed
    And the provider has "finance" switch allowed
    When I go to the new CMS groups page
    Then finance should show in the permissions list
