Feature: Provider stats section authorization
  In order to manage my stats
  As a provider
  I want to control who can access the stats area

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has Browser CMS activated
    And an account plan "account plan" of provider "foo.example.com"
    And an application plan "app plan" of provider "foo.example.com"
    And a service plan "serv plan" of provider "foo.example.com"
    And all the rolling updates features are off

  Scenario Outline: Provider admin can access stats
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    When I go to the provider dashboard
    Then I should see the link "Analytics" in the apis dashboard widget
    When I follow "Analytics"
    Then I should see the link "Analytics" in the main menu

    When I go to the <page> page
    Then I should be on the <page> page
  Examples:
      | page                     |
      | provider stats usage     |
      | provider stats apps      |
      | provider stats days      |
      | provider stats hours     |


  Scenario Outline: Members per default cannot access stats
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "monitoring" of provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
      And I go to the provider dashboard
    Then I should not see the link "Analytics" in the apis dashboard widget

    When I request the url of the '<page>' page then I should see an exception
  Examples:
      | page                     |
      | provider stats usage     |
      | provider stats apps      |
      | provider stats days      |
      | provider stats hours     |


  Scenario Outline: Members of stats group can access stats
   Given an active user "member" of account "foo.example.com"
     And user "member" has access to the admin section "monitoring"
     And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "member"
     And I go to the provider dashboard
    Then I should see "Analytics" in the apis dashboard widget
    When I follow "Analytics"
    Then I should see the link "Analytics" in the main menu

    When I go to the <page> page
    Then I should be on the <page> page
  Examples:
      | page                     |
      | provider stats usage     |
      | provider stats apps      |
      | provider stats days      |
      | provider stats hours     |
