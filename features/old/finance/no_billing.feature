Feature: Provider billing mode off
  In order not be confused
  As a buyer
  I don't want to see any invoices if I my provider does not support it

  Background:
   Given a provider "xyz.example.com" with billing disabled
     And an application plan "RandomPlan" of provider "xyz.example.com" for 666 monthly
     And a buyer "kyle" signed up to application plan "RandomPlan"
     And admin of account "kyle" has email "kyle@example.com"

  Scenario: I don't want to be bugged by invoice information
    Given I log in as "kyle" on xyz.example.com
      And I go to the account page
     Then I should not see link "Invoices"
#	   And visiting the URL <whatever it is> should fail.

  Scenario: I don't want to get any emails with invoices
    Given the time is 15th January 2009
    And 1 months passes
    Then the date should be 15th February 2009
    Then "kyle@example.com" should receive 0 emails
