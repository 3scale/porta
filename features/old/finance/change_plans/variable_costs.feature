@stats
Feature: Change plan
  In order to adapt to my changing requirements
  As a buyer
  I want to upgrade or downgrade my plan

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" is charging its buyers
      And all the rolling updates features are on
    Given an application plan "CheapPlan" of provider "foo.3scale.localhost" for 0 monthly
      And an application plan "ExpensivePlan" of provider "foo.3scale.localhost" for 0 monthly
    Given the current domain is foo.3scale.localhost
      And pricing rules on plan "CheapPlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |             1 |   1 | infinity |
      And pricing rules on plan "ExpensivePlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |            10 |   1 | infinity |

      @wip
  Scenario: Keeps price of the moment of the hit was done even if plan doesn't change.
    Given the time is 1st May 2009
      And provider "foo.3scale.localhost" is charging its buyers in prepaid mode
      And a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      And pricing rules on plan "CheapPlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |             2 |   1 | infinity |
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      And time flies to 3rd June 2009
      When I log in as "stallman" on foo.3scale.localhost
      And I navigate to Invoices issued for me
      Then I should see "EUR 2.00"
      # should be 3

  Scenario: Change plan with variable costs in both plans in the same month (PREPAID)
    Given the time is 1st May 2009
      And provider "foo.3scale.localhost" is charging its buyers in prepaid mode
      And a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      When I log in as "stallman" on foo.3scale.localhost
      And I change application plan to "ExpensivePlan" on 15th May 2009 UTC
      When time flies to 16th May 2009
      Then I should have 0 invoices
      When time flies to 20th May 2009
      Then I should have 1 invoices
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      And I navigate to Invoices issued for me
     Then I should see "EUR 10.00"
      And I should see "EUR 1.00"

  Scenario: Change plan with variable costs in both plans in the same month. Provider sees it the day after. Buyer end of month (PREPAID)
    Given the time is 1st May 2009
      And provider "foo.3scale.localhost" is charging its buyers in prepaid mode
      And a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      When I log in as "stallman" on foo.3scale.localhost
      And I change application plan to "ExpensivePlan" on 15th May 2009 UTC
      When time flies to 16th May 2009
       And current domain is the admin domain of provider "foo.3scale.localhost"
       And I log in as provider "foo.3scale.localhost"
       And I navigate to my earnings
       And follow "May, 2009"
      Then I should see "EUR 1.00"
      Then buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      Then I should have an invoice of "10.0 EUR"
      And I should have an invoice of "1.0 EUR"

  Scenario: Change plan with variable costs in both plans in the same month (POSTPAID)
    Given the time is 1st May 2009
      And a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      When I log in as "stallman" on foo.3scale.localhost
      And I change application plan to "ExpensivePlan" on 15th May 2009 UTC
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      And I navigate to Invoices issued for me
      #And I navigate to invoice issued for me in "May, 2009"
      Then I should see "EUR 11.00"
      # should be 11

  Scenario: No variable costs are charged if the cinstance now is in a plan in trial period
    Given plan "ExpensivePlan" has trial period of 25 days
    Given the time is 1st May 2009
      And a buyer "stallman" signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When time flies to 15th May 2009
      When I log in as "stallman" on foo.3scale.localhost
      And I change application plan to "ExpensivePlan" on 15th May 2009 UTC
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And time flies to 3rd June 2009
      And I navigate to Invoices issued for me
      And I navigate to invoice issued for me in "May, 2009"
      Then I should see "EUR 1.00"


  # Scenario: if user changes plans twice, and first job fails, the second one can succeed and bill the big period with its rules
