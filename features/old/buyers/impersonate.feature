@javascript
Feature: Impersonate
  In order to get the same user experience and possibilities as other users of the site
  As a master account admin
  I want to impersonate them

  Background:
    Given the master account admin has username "master" and password "superSecret1234#"
    And a provider "foo.3scale.localhost" with impersonation_admin admin
    And a provider "bar.3scale.localhost"

  Scenario: Impersonate impersonation_admin user of the account
    When I am logged in as master admin on master domain
    And I navigate to the accounts page
    Then I should not see link "Act as" for provider "bar.3scale.localhost"
    When I follow "Act as" for account "foo.3scale.localhost"
    Then the current domain in a new window should be admin.foo.3scale.localhost
    And I should be logged in as "impersonation_admin"
