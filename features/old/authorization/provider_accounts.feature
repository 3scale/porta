Feature: Provider accounts authorization
  In order to manage my accounts
  As a provider
  I want to control who can access the accounts area

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has Browser CMS activated
    Given provider "foo.example.com" has multiple applications enabled
      And a buyer "buyer" signed up to provider "foo.example.com"

  Scenario Outline: Provider admin can access accounts
    Given current domain is the admin domain of provider "foo.example.com"
    Given provider "foo.example.com" has "groups" switch allowed
    Given provider "foo.example.com" has "multiple_users" switch allowed
    When I log in as provider "foo.example.com"

    When I go to the provider dashboard
    #Then show me the page
    Then I should see the link "1 Account" in the audience dashboard widget
    When I follow "1 Account"
    Then I should see the link "Accounts" in the main menu

    When I go to the <page> page
    Then I should be at url for the <page> page

    Examples:
      | page                                 |
      | buyer accounts                       |
      | approved buyer accounts              |
      | pending buyer accounts               |
      | rejected buyer accounts              |
      | new buyer account                    |
      | buyer account "buyer"                |
      | buyer account "buyer" edit           |
      | buyer account "buyer" users          |
      | buyer user "buyer"                   |
      | buyer user "buyer" edit              |
      | buyer account "buyer" invitations    |
      | buyer account "buyer" new invitation |
      | buyer account "buyer" groups         |


  Scenario Outline: Members per default cannot access accounts
   Given an active user "member" of account "foo.example.com"
     And user "member" does not belong to the admin group "partners" of provider "foo.example.com"

     And current domain is the admin domain of provider "foo.example.com"
    Given provider "foo.example.com" has "groups" switch allowed
    Given provider "foo.example.com" has "multiple_users" switch allowed
    When I log in as provider "member"

     And I go to the provider dashboard
    Then I should not see the link "Accounts" in the audience dashboard widget

    When I request the url of the '<page>' page then I should see an exception

    Examples:
      | page                                 |
      | buyer accounts                       |
      | approved buyer accounts              |
      | pending buyer accounts               |
      | rejected buyer accounts              |
      | new buyer account                    |
      | buyer account "buyer"                |
      | buyer account "buyer" edit           |
      | buyer account "buyer" users          |
      | buyer user "buyer"                   |
      | buyer user "buyer" edit              |
      | buyer account "buyer" invitations    |
      | buyer account "buyer" new invitation |
      | buyer account "buyer" groups         |


  Scenario Outline: Members of partners group can access accounts
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "partners"
      And current domain is the admin domain of provider "foo.example.com"
      And provider "foo.example.com" has "multiple_users" switch allowed
     When I log in as provider "member"
      And I go to the provider dashboard
    Then I should see the link "1 Account" in the audience dashboard widget

    When I go to the <page> page
    Then I should be at url for the <page> page

    Examples:
      | page                                 |
      | buyer accounts                       |
      | approved buyer accounts              |
      | pending buyer accounts               |
      | rejected buyer accounts              |
      | new buyer account                    |
      | buyer account "buyer"                |
      | buyer account "buyer" edit           |
      | buyer account "buyer" users          |
      | buyer user "buyer"                   |
      | buyer user "buyer" edit              |
      | buyer account "buyer" invitations    |
      | buyer account "buyer" new invitation |


  Scenario: Members of partners group can activate and approve accounts
    Given an active user "member" of account "foo.example.com"
    And user "member" has access to the admin section "partners"
    And current domain is the admin domain of provider "foo.example.com"
    And provider "foo.example.com" has "multiple_users" switch allowed
    Given a pending buyer "pending account" signed up to provider "foo.example.com"

    When I log in as provider "member"
    And I follow "2 Accounts"
    And I follow "Approve"
    Then I should see "Developer account was approved"
