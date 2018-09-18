Feature: Provider lists all invoices
  In order to manage all my invoices
  As a provider
  I want to search, sort and filter all my invoices

  Background:
    # TODO: Create invoices directly from background
    Given a provider "foo.example.com" with billing enabled
      And current domain is the admin domain of provider "foo.example.com"
    Given provider "foo.example.com" has "finance" switch allowed
      And an application plan "Fixed" of provider "foo.example.com" for 200 monthly
      And the date is 5th October 2010
      And a buyer "foobar" signed up to application plan "Fixed"
      And time flies to 10th February 2011
      And a buyer "mastermind" signed up to application plan "Fixed"
      And time flies to 20th April 2011

    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

  Scenario: Filter invoices
      When I navigate to invoices issued by me
      Then I should see 10 invoices

      When I select "January" from "search[month_number]" within search form
       And I press "Search"
      Then I should see 1 invoice

      When I select "March" from "search[month_number]" within search form
       And I press "Search"
      Then I should see 2 invoices

      When I navigate to invoices issued by me
      Then I should see 10 invoices

      When I fill in "search[number]" with "2010-1*-*" within search form
       And I press "Search"
      Then I should see 3 invoices

      When I fill in "search[number]" with "2011-01-*" within search form
       And I press "Search"
      Then I should see 1 invoice

      When I fill in "search[number]" with "2011-04-*" within search form
       And I press "Search"
      Then I should see 2 invoices

      When I navigate to invoices issued by me
       And I select "pending" from "search[state]" within search form
       And I press "Search"
      Then I should see 8 invoices

      When I fill in "search[number]" with "2011-*" within search form
       And I press "Search"
      Then I should see 5 invoices

      When I fill in "search[number]" with "" within search form
       And select "2011" from "search[year]" within search form
       And I press "Search"
      Then I should see 5 invoices

      When I navigate to invoices issued by me
        And I follow "Account" within "table"
        Then I should see 10 invoices
        Then I should see the first invoice belonging to "foobar"
        And I follow "Account ▲" within "table"
        Then I should see 10 invoices
        Then I should see the first invoice belonging to "mastermind"

  Scenario: Filter deleted accounts
     When account "mastermind" is deleted
      And I navigate to invoices issued by me
     Then I should see 10 invoices
