@javascript
Feature: Provider lists all invoices
  In order to manage all my invoices
  As a provider
  I want to search, sort and filter all my invoices

  Background:
    # TODO: Create invoices directly from background
    Given a provider is logged in on 1st October 2010
    And the provider is billing but not charging
    And the default service of the provider has name "My API"
    And the following application plans:
      | Product | Name   | Cost per month |
      | My API  | Fixed  | 200            |
    And the date is 5th October 2010
    And a buyer "foobar" signed up to application plan "Fixed"
    And time flies to 10th February 2011
    And a buyer "mastermind" signed up to application plan "Fixed"
    And time flies to 20th April 2011

  @commit-transactions
  Scenario: Filter invoices
    When I go to invoices issued by me
    Then I should see 10 invoices
    When I select "January" from "search[month_number]" within the search form
    And I press "Search"
    Then I should see 1 invoice
    When I select "March" from "search[month_number]" within the search form
    And I press "Search"
    Then I should see 2 invoices
    When I go to invoices issued by me
    Then I should see 10 invoices
    When I fill in "search[number]" with "2010-1*-*" within the search form
    And I press "Search"
    Then I should see 3 invoices
    When I fill in "search[number]" with "2011-01-*" within the search form
    And I press "Search"
    Then I should see 1 invoice
    When I fill in "search[number]" with "2011-04-*" within the search form
    And I press "Search"
    Then I should see 2 invoices
    When I go to invoices issued by me
    And I select "pending" from "search[state]" within the search form
    And I press "Search"
    Then I should see 8 invoices
    When I fill in "search[number]" with "2011-*" within the search form
    And I press "Search"
    Then I should see 5 invoices
    When I fill in "search[number]" with "" within the search form
    And select "2011" from "search[year]" within the search form
    And I press "Search"
    Then I should see 5 invoices
    When I go to invoices issued by me
    And I follow "Account" within the table
    Then I should see 10 invoices
    Then I should see the first invoice belonging to "foobar"
    And I follow "Account" within the table
    Then I should see 10 invoices
    Then I should see the first invoice belonging to "mastermind"

  Scenario: Filter deleted accounts
    When account "mastermind" is deleted
    And I go to invoices issued by me
    Then I should see 10 invoices
