Feature: Provider lists all invoices
  In order to manage all my invoices
  As a provider
  I want to search, sort and filter all my invoices and only see mine

  Background:
    # TODO: Create invoices directly from background
    Given a provider "xyz.3scale.localhost"
      And provider "xyz.3scale.localhost" is billing but not charging
    Given a provider "other.3scale.localhost"
      And provider "other.3scale.localhost" is billing but not charging

    Given an application plan "Fixed" of provider "xyz.3scale.localhost" for 200 monthly
      And an application plan "Fixed_for_other" of provider "other.3scale.localhost" for 200 monthly
      And the date is 5th October 2010
      And a buyer "foobar" signed up to application plan "Fixed"
      And a buyer "other_buyer" signed up to application plan "Fixed_for_other"
      And time flies to 10th February 2011
      And a buyer "mastermind" signed up to application plan "Fixed"
      And time flies to 20th April 2011

  Scenario: Filter invoices on other
      Given I log in as "other.3scale.localhost" on the admin domain of provider "other.3scale.localhost"
      And I navigate to invoices issued by me
      Then I should see 7 invoices

  @commit-transactions
  Scenario: Filter invoices
      Given I log in as "xyz.3scale.localhost" on the admin domain of provider "xyz.3scale.localhost"
        And I navigate to invoices issued by me

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

  Scenario: Filter deleted accounts
    Given account "mastermind" is deleted

    Given I log in as "xyz.3scale.localhost" on the admin domain of provider "xyz.3scale.localhost"
      And I navigate to invoices issued by me

     Then I should see 10 invoices
