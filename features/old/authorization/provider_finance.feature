Feature: Provider finance authorization
  In order to manage my finance
  As a provider
  I want to control who can access the finance area

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has Browser CMS activated
      And provider "foo.example.com" has billing enabled

  Scenario Outline: Provider admin can access finance
   Given current domain is the admin domain of provider "foo.example.com"
     And I am logged in as provider "foo.example.com"
    When I go to the provider dashboard
    Then I should see "Billing"

    When I go to the <page> page
    Then I should be on the <page> page
  Examples:
    | page                |
    | finance             |
    | finance settings    |


  Scenario Outline: Members per default cannot access finance
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "finance" of provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
      And I go to the provider dashboard
    Then I should not see "Billing"

    When I request the url of the '<page>' page then I should see an exception
  Examples:
    | page                |
    | finance             |
    | finance settings    |


  Scenario Outline: Members of finance group can access finance
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "finance"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
      And I go to the provider dashboard
     Then I should see "Billing"

    When I go to the <page> page
    Then I should be on the <page> page
  Examples:
    | page                |
    | finance             |
    | finance settings    |
