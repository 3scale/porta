Feature: Provider billing mode off
  In order not be confused
  As a buyer
  I don't want to see any invoices if I my provider does not support it

  Background:
   Given a provider "xyz.3scale.localhost" with billing disabled
     And an application plan "RandomPlan" of provider "xyz.3scale.localhost" for 666 monthly
     And a buyer "kyle" signed up to application plan "RandomPlan"
     And admin of account "kyle" has email "kyle@3scale.localhost"

  Scenario: I don't want to be bugged by invoice information
    Given I log in as "kyle" on "xyz.3scale.localhost"
      And I go to the account page
     Then I should not see link "Invoices"
#	   And visiting the URL <whatever it is> should fail.

  Scenario: I don't want to get any emails with invoices
    Given the time is 15th January 2009
    And 1 months passes
    Then the date should be 15th February 2009
    Then "kyle@3scale.localhost" should receive 0 emails
