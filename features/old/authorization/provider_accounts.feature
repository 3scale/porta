@javascript
Feature: Provider accounts authorization
  In order to manage my accounts
  As a provider
  I want to control who can access the accounts area

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_applications" visible
    And a buyer "buyer" signed up to provider "foo.3scale.localhost"

  Scenario: Provider admin can access accounts
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "groups" switch allowed
    And provider "foo.3scale.localhost" has "multiple_users" switch allowed
    When I log in as provider "foo.3scale.localhost"

    When I go to the provider dashboard
    #Then show me the page
    Then I should see the link "1 ACCOUNT" within the audience dashboard widget
    When I follow "1 Account"
    Then I should see "Accounts" within the main menu
    And they should be able to go to the following pages:
      | the buyer accounts page                       |
      | the approved buyer accounts page              |
      | the pending buyer accounts page               |
      | the rejected buyer accounts page              |
      | the new buyer account page                    |
      | the buyer account "buyer" page                |
      | the buyer account "buyer" edit page           |
      | the buyer account "buyer" users page          |
      | the buyer user "buyer" page                   |
      | the buyer user "buyer" edit page              |
      | the buyer account "buyer" invitations page    |
      | the buyer account "buyer" new invitation page |
      | the buyer account "buyer" groups page         |

  Scenario: Members per default cannot access accounts
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" does not belong to the admin group "partners" of provider "foo.3scale.localhost"

    And current domain is the admin domain of provider "foo.3scale.localhost"
    Given provider "foo.3scale.localhost" has "groups" switch allowed
    Given provider "foo.3scale.localhost" has "multiple_users" switch allowed
    When I log in as provider "member"

    And I go to the provider dashboard
    Then I should not see the link "ACCOUNTS" within the audience dashboard widget

    Then they should see an error when going to the following pages:
      | the buyer accounts page                       |
      | the approved buyer accounts page              |
      | the pending buyer accounts page               |
      | the rejected buyer accounts page              |
      | the new buyer account page                    |
      | the buyer account "buyer" page                |
      | the buyer account "buyer" edit page           |
      | the buyer account "buyer" users page          |
      | the buyer user "buyer" page                   |
      | the buyer user "buyer" edit page              |
      | the buyer account "buyer" invitations page    |
      | the buyer account "buyer" new invitation page |
      | the buyer account "buyer" groups page         |

  Scenario: Members of partners group can access accounts
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "partners"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_users" switch allowed
    When I log in as provider "member"
    And I go to the provider dashboard
    Then I should see the link "1 ACCOUNT" within the audience dashboard widget
    And they should be able to go to the following pages:
      | the buyer accounts page                       |
      | the approved buyer accounts page              |
      | the pending buyer accounts page               |
      | the rejected buyer accounts page              |
      | the new buyer account page                    |
      | the buyer account "buyer" page                |
      | the buyer account "buyer" edit page           |
      | the buyer account "buyer" users page          |
      | the buyer user "buyer" page                   |
      | the buyer user "buyer" edit page              |
      | the buyer account "buyer" invitations page |
      | the buyer account "buyer" new invitation page |

  Scenario: Members of partners group can activate and approve accounts
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "partners"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_users" switch allowed
    Given a pending buyer "pending account" signed up to provider "foo.3scale.localhost"

    When I log in as provider "member"
    And I follow "2 Accounts"
    And I follow "Approve"
    Then I should see "Developer account was approved"
