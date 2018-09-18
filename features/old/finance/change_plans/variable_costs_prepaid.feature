@stats
Feature: Change plan
  In order to adapt to my changing requirements
  As a buyer
  I want to upgrade or downgrade my plan

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch visible
      And all the rolling updates features are on
      And provider "foo.example.com" has prepaid billing enabled
    Given an application plan "CheapPlan" of provider "foo.example.com" for 0 monthly
      And an application plan "ExpensivePlan" of provider "foo.example.com" for 0 monthly
    Given the current domain is foo.example.com
      And pricing rules on plan "CheapPlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |             1 |   1 | infinity |
      And pricing rules on plan "ExpensivePlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |            10 |   1 | infinity |

  Scenario: Change plan with variable costs in both plans in the same month (PREPAID)
    Given a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      When I log in as "stallman" on foo.example.com
      And I change application plan to "ExpensivePlan" on 15th May 2009 UTC
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      And I navigate to Invoices issued for me
      Then I should see "EUR 1.00"
      Then I should see "EUR 10.00"


  Scenario: Change plan with variable costs in both plans in the same month. Provider sees it the day after. Buyer end of month (PREPAID)
    Given a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      When I log in as "stallman" on foo.example.com
      And I change application plan to "ExpensivePlan" on 15th May 2009 UTC
      When time flies to 16th May 2009
       And current domain is the admin domain of provider "foo.example.com"
       And I log in as provider "foo.example.com"
       And I navigate to my earnings
     Then I should have an invoice of "1.0 EUR"
      Then buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
     Then I should have an invoice of "10.0 EUR"
     Then I should have an invoice of "1.0 EUR"

  Scenario: Hit and change plan the next day bills hit on the old plan
    Given a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 2nd May 2009
      When I log in as "stallman" on foo.example.com
      And I change application plan to "ExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      And I navigate to Invoices issued for me
      Then I should see "EUR 1.00"
      Then I should see "EUR 10.00"

  Scenario: Hit and change plan the same day bills hit on the new plan
    Given a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When I log in as "stallman" on foo.example.com
      And I change application plan to "ExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      And I navigate to Invoices issued for me
      Then I should see "EUR 20.00"

  Scenario: Variable costs are charged if the cinstance now is in a plan in trial period PREPAID
    Given plan "ExpensivePlan" has trial period of 25 days
    Given the time is 1st May 2009
      And a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      When I log in as "stallman" on foo.example.com
      And I change application plan to "ExpensivePlan" on 16th May 2009 UTC
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      And I navigate to Invoices issued for me
      Then I should have 2 invoices
       And I should see "EUR 1.00"
       And I should see "EUR 10.00"

  Scenario: 2 plan changes in one month PREPAID
      Given a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
        And buyer "stallman" makes 1 service transactions with:
        | Metric | Value |
        | hits   |     1 |
      When I log in as "stallman" on foo.example.com on 15th May 2009
      And I change application plan to "ExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      When I log in as "stallman" on foo.example.com on 17th May 2009
      And I change application plan to "CheapPlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And I navigate to Invoices issued for me on 3rd June 2009
     Then I should see "2009-06-00000001 June, 2009 pending EUR 1.00"
      And I should see "2009-05-00000002 May, 2009 failed EUR 10.00"
      And I should see "2009-05-00000001 May, 2009 failed EUR 1.00"
