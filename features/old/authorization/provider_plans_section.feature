Feature: Provider plans section authorization
  In order to manage my plans
  As a provider
  I want to control who can access the plans area

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has Browser CMS activated
      And provider "foo.example.com" has "account_plans" switch allowed
      And provider "foo.example.com" has "service_plans" visible

      And an account plan "account plan" of provider "foo.example.com"
      And an application plan "app plan" of provider "foo.example.com"
      And a service plan "serv plan" of provider "foo.example.com"

    Given provider "foo.example.com" has "account_plans" switch allowed


  Scenario Outline: Provider admin can access plans
    Given current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "foo.example.com"
     When I go to the provider dashboard
     Then I should see "API" in the main menu

    When I go to the <page> page
    Then I should be at url for the <page> page
  Examples:
      | page                            |
      | API dashboard                   |
      | account plans admin             |
      | application plans admin         |
      | service plans admin             |
      | edit for plan "account plan"    |
      | edit for plan "serv plan"       |
      | edit for plan "app plan"        |


  Scenario Outline: Members per default cannot access plans
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "plans" of provider "foo.example.com"
     And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
      And I go to the provider dashboard

    Then I should not see "API" in the main menu

    When I request the url of the '<page>' page then I should see an exception
  Examples:
      | page                            |
      | API dashboard                   |
    # | plans home admin                |
      | account plans admin             |
      | application plans admin         |
      | service plans admin             |
      | edit for plan "account plan"    |
      | edit for plan "serv plan"       |
      | edit for plan "app plan"        |
    # | latest transactions |
    # | transaction errors  |

  Scenario Outline: Members of plans group can access plans
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "plans"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
      And I go to the provider dashboard
     Then I should see "API" in the main menu

    When I go to the <page> page
    Then I should be at url for the <page> page
  Examples:
      | page                            |
      | API dashboard                   |
    # | plans home admin                |
      | account plans admin             |
      | application plans admin         |
      | service plans admin             |
      | edit for plan "account plan"    |
      | edit for plan "serv plan"       |
      | edit for plan "app plan"        |
    # | latest transactions |
    # | transaction errors  |
