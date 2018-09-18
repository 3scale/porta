Feature: Provider settings authorization
  In order to manage my settings
  As a provider
  I want to control who can access the settings area

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has Browser CMS activated

  Scenario Outline: Provider admin can access settings
     And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "foo.example.com"

    When I go to the provider dashboard
    Then I should see the link Settings in the main menu

    When I go to the <page> page
    Then I should be on the <page> page

    Examples:
      | page                 |
      | edit site settings   |
      | usage rules settings |
      | dns settings         |


  Scenario Outline: Members per default cannot access settings
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "settings" of provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
     And I go to the provider dashboard
    Then I should not see the link Settings in the main menu

    When I request the url of the '<page>' page then I should see an exception

    Examples:
      | page                 |
      | site settings        |
      | edit site settings   |
      | usage rules settings |
      | dns settings         |


  Scenario Outline: Members of settings group can access settings
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "settings"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
      And I go to the provider dashboard
     Then I should see the link Settings in the main menu

    When I go to the <page> page
    Then I should be on the <page> page

    Examples:
      | page                 |
      | edit site settings   |
      | usage rules settings |
      | dns settings         |
