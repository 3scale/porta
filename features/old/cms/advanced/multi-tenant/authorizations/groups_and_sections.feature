Feature: Groups and permissions
  In order to access my allowed pages on the bcms
  As a buyer
  I want to access my allowed pages and ONLY my allowed pages

  Background:
    # Given we have 2 enterprise providers
    Given a provider "one.example.com"
      And provider "one.example.com" has multiple applications enabled
    #
    Given a provider "two.example.com"
      And provider "two.example.com" has multiple applications enabled

    # Given both providers have a page with path "/docs", but one is restricted, while the other is not
    Given provider "one.example.com" has a private section "Docs" with path "/docs"
      And provider "one.example.com" has a published page with the title "First of one" and path "/first" of section "Docs"
    #
    Given provider "two.example.com" has a public section "Docs" with path "/docs"
      And provider "two.example.com" has a published page with the title "First of two" and path "/first" of section "Docs"

    Given an approved buyer "one_buyer" signed up to provider "one.example.com"
    Given an approved buyer "one_buyer" signed up to provider "two.example.com"

    # Given both providers have restricted pages "/ducks"
    Given provider "one.example.com" has a private section "Ducks" with path "/ducks"
      And provider "one.example.com" has a published page with the title "Duck of one" and path "/ducks" of section "Ducks"
    #
    Given provider "two.example.com" has a private section "Ducks" with path "/ducks"
      And provider "two.example.com" has a published page with the title "Duck of two" and path "/ducks" of section "Ducks"

    # Given one provider has granted access to his restricted page, while the other has not
    Given the buyer "one_buyer" has access to the section "Ducks" of provider "one.example.com"
    Given the buyer "one_buyer" has access to the section "Ducks" of provider "two.example.com"

  # non logged users
  Scenario: Public sections are public even when there is another restricted one with same path that iss restricted
    Given the current domain is "two.example.com"
    When I request the url "/first"
    Then I should see "First of two"

  @allow-rescue
  Scenario: Restricted sections are restricted even when there is another one public with same path that is public
    Given the current domain is "one.example.com"
    When I request the url "/first"
    Then I should get 404

  # logged users
  Scenario: sections are accessible to permitted buyers even when another provider has a restricted section with same path
    Given I am logged in as "one_buyer" on two.example.com
    When I request the url "/first"
    Then I should see "First of two"

  @allow-rescue
  Scenario: sections are restricted to buyers even when another provider has a public section with same path
    Given I am logged in as "one_buyer" on one.example.com
    When I request the url "/first"
    Then I should get 404

  Scenario: Each one sees its contents
    Given I am logged in as "one_buyer" on two.example.com
    When I request the url "/ducks"
    Then I should see "Duck of two"

    Given I am logged in as "one_buyer" on one.example.com
    When I request the url "/ducks"
    Then I should see "Duck of one"
