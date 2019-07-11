@backend @ignore-backend
Feature: Providers's application referrer filters
  In order specify where applications of my buyers can be used from
  As a provider
  I want to define referrer filters

  Background:
    Given a provider "foo.example.com"
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And referrer filters are required for the service of provider "foo.example.com"
    And a default application plan of provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" has application "SpookyWidget"
    And current domain is the admin domain of provider "foo.example.com"

  Scenario: List referrer filters
    Given the application of buyer "bob" has the following referrer filters:
      | foo.example.org |
      | bar.example.org |
    When I log in as provider "foo.example.com"
    And I go to the provider side "SpookyWidget" application page
    Then I should see referrer filter "foo.example.org"
    And I should see referrer filter "bar.example.org"

  Scenario: Create a referrer filter
    Given application "SpookyWidget" has no referrer filters
    And the backend will create referrer filter "foo.example.org" for application "SpookyWidget"
    When I log in as provider "foo.example.com"
    And I go to the provider side "SpookyWidget" application page
    And I submit the new referrer filter form with "foo.example.org"
    Then I should see referrer filter "foo.example.org"

  @evil @wip
  Scenario: Delete a referrer filter
    Given application "SpookyWidget" has the following referrer filters:
      | foo.example.org |
    And the backend will delete referrer filter "foo.example.org" for application "SpookyWidget"
    When I log in as provider "foo.example.com"
    And I go to the provider side "SpookyWidget" application page
    And I press "Delete" for referrer filter "foo.example.org"
    Then I should not see referrer filter "foo.example.org"

  Scenario: Referrer filters are not shown if not required
    Given referrer filters are not required for the service of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider side "SpookyWidget" application page
    Then I should not see "Referrer Filters"
