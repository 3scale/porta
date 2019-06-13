Feature: Impersonate
  In order to get the same user experience and posibilities as other users of the site
  As a master account admin
  I want to impersonate them

  Background:
    Given the master account admin has username "master" and password "supersecret"
    And a provider "foo.example.com" with impersonation_admin admin
    And a provider "bar.example.com"

  Scenario: Impersonate impersonation_admin user of the account
    When I am logged in as master admin on master domain
     And I navigate to the accounts page
    Then I should not see link "Act as" for provider "bar.example.com"
    When I follow "Act as" for account "foo.example.com"
    Then I should see "Signed in successfully"
    And I should be logged in as "impersonation_admin"
    And the current domain should be the admin domain of provider "foo.example.com"

