@no-txn
Feature: Groups and permissions
  In order to access my allowed pages on the bcms
  As a buyer
  I want to access my allowed pages and ONLY my allowed pages

  Background:
    # Given we have 2 enterprise providers
    Given a provider "one.3scale.localhost"
      And provider "one.3scale.localhost" has "multiple_applications" visible
    #
    Given a provider "two.3scale.localhost"
      And provider "two.3scale.localhost" has "multiple_applications" visible

    Given provider "one.3scale.localhost" has the following sections:
      | Title | Partial path | Public |
      | Docs  | /docs        | False  |
      | Ducks | /ducks       | False  |
    And provider "one.3scale.localhost" has the following pages:
      | Title        | Section | Path   | Published    |
      | First of one | Docs    | /first | First of one |
      | Duck of one  | Ducks   | /ducks | Duck of one  |

    Given provider "two.3scale.localhost" has the following sections:
      | Title | Partial path | Public |
      | Docs  | /docs        | True   |
      | Ducks | /ducks       | False  |
    And provider "two.3scale.localhost" has the following pages:
      | Title        | Section | Path   | Published    |
      | First of two | Docs    | /first | First of two |
      | Duck of two  | Ducks   | /ducks | Duck of two  |

    Given an approved buyer "one_buyer" signed up to provider "one.3scale.localhost"
    And the buyer has access to section "Ducks" of provider "one.3scale.localhost"

    Given an approved buyer "one_buyer" signed up to provider "two.3scale.localhost"
    And the buyer has access to section "Ducks" of provider "two.3scale.localhost"

  # non logged users
  Scenario: Public sections are public even when there is another restricted one with same path that iss restricted
    Given the current domain is "two.3scale.localhost"
    When I request the url "/first"
    Then I should see "First of two"

  @allow-rescue
  Scenario: Restricted sections are restricted even when there is another one public with same path that is public
    Given the current domain is "one.3scale.localhost"
    When I request the url "/first"
    Then I should see "Not found"

  # logged users
  Scenario: sections are accessible to permitted buyers even when another provider has a restricted section with same path
    Given I am logged in as "one_buyer" on two.3scale.localhost
    When I request the url "/first"
    Then I should see "First of two"

  @allow-rescue
  Scenario: sections are restricted to buyers even when another provider has a public section with same path
    Given I am logged in as "one_buyer" on one.3scale.localhost
    When I request the url "/first"
    Then I should see "Not found"

  Scenario: Each one sees its contents
    Given I am logged in as "one_buyer" on two.3scale.localhost
    When I request the url "/ducks"
    Then I should see "Duck of two"

    Given I am logged in as "one_buyer" on one.3scale.localhost
    When I request the url "/ducks"
    Then I should see "Duck of one"
