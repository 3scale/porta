#TODO feature makes no sense now
@wip
Feature: Provider account management
  In order to have control over the providers accounts signed up to the system
  As the master account admin
  I want to be able to manage the accounts

  Background:
    Given a provider "foo.3scale.localhost"
    When I log in as "superadmin" on the master domain

  Scenario: Show and edit account details
    When I follow "Accounts"
     And I follow "foo.3scale.localhost"
    Then I should see "Account Summary" in a header
     And I should see "Provider Key" within the application widget

    When I follow "Edit"
     And I fill in the following:
     | Vat code    | AAA  |
     | Fiscal code | BBB  |
     | Vat rate    | 6.78 |
     And I press "Update Account"
    Then I should see "BBB"
     And I should see "6.78"

  Scenario: Test application does not show in the application widget
    Given provider "foo.3scale.localhost" has test application
    When I follow "Accounts"
      And I follow "foo.3scale.localhost"
    Then I should not see "Application on plan test" within the application widget

