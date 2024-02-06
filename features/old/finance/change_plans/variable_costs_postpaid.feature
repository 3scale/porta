@stats
Feature: Change plan
  In order to adapt to my changing requirements
  As a buyer
  I want to upgrade or downgrade my plan

  Background:
    Given a provider "foo.3scale.localhost" on 1st May 2009
      And provider "foo.3scale.localhost" is charging its buyers in postpaid mode
      And provider "foo.3scale.localhost" has "finance" switch visible
      And all the rolling updates features are on
      And the default product of the provider has name "My API"
      And the following application plans:
        | Product | Name              | Cost per month |
        | My API  | CheapPlan         | 0              |
        | My API  | ExpensivePlan     | 0              |
        | My API  | VeryExpensivePlan | 0              |
    Given the current domain is foo.3scale.localhost
      And pricing rules on plan "CheapPlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |             1 |   1 | infinity |
      And pricing rules on plan "ExpensivePlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |            10 |   1 | infinity |
      And pricing rules on plan "VeryExpensivePlan":
      | Metric | Cost per unit | Min | Max      |
      | hits   |           100 |   1 | infinity |
    And a buyer "stallman"

  Scenario: Change plan with variable costs in both plans in the same month (POSTPAID)
    Given the buyer is signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When I log in as "stallman" on foo.3scale.localhost on 15th May 2009
      And the buyer changes to application plan "ExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And I navigate to Invoices issued for me on 3rd June 2009
      Then I should see "EUR 11.00"

  @javascript
  Scenario: Hit and change plan the next day bills hit on the old plan
    Given the buyer is signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost on 2nd May 2009
       And the buyer changes to application plan "ExpensivePlan"
       And current domain is the admin domain of provider "foo.3scale.localhost" on 16th May 2009
       And I log in as provider "foo.3scale.localhost"

      Then I should have an invoice of "1.0 EUR"
      Then buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And I go to my earnings on 3rd June 2009
      Then I should have an invoice of "11.0 EUR"

  @javascript
  Scenario: Hit and change plan the same day bills hit on the new plan
    Given the buyer is signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost
       And the buyer changes to application plan "ExpensivePlan"
      Then buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And current domain is the admin domain of provider "foo.3scale.localhost" on 3rd June 2009
      Then I log in as provider "foo.3scale.localhost"
     Then I should have an invoice of "20.0 EUR"

  @javascript
  Scenario: Change plan. Provider sees the invoice the day after. (POSTPAID)
    Given the buyer is signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost on 15th May 2009
       And the buyer changes to application plan "ExpensivePlan"
       And current domain is the admin domain of provider "foo.3scale.localhost" on 16th May 2009
       And I log in as provider "foo.3scale.localhost"
      Then I should have an invoice of "1.0 EUR"

  Scenario: Variable costs are charged if the cinstance now is in a plan in trial period POSTPAID
    # Only one trial period per account. if you change to a plan with
    # trial period, no trial for you anyway
    Given plan "ExpensivePlan" has a trial period of 25 days
    Given the time is 1st May 2009
      And the buyer is signed up to application plan "CheapPlan" on 1st May 2009
      And buyer "stallman" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    1 |
      When I log in as "stallman" on foo.3scale.localhost on 16th May 2009
      And the buyer changes to application plan "ExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And I navigate to Invoices issued for me on 3rd June 2009
      Then I should have 1 invoice
      And I navigate to invoice issued for me in "May, 2009"
      Then I should see "EUR 1.00"
      Then I should see "EUR 10.00"

  Scenario: 2 plan changes in one month POSTPAID
      Given the buyer is signed up to application plan "CheapPlan" on 1st May 2009
        And buyer "stallman" makes 1 service transactions with:
        | Metric | Value |
        | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost on 15th May 2009
      And the buyer changes to application plan "ExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost on 17th May 2009
      And the buyer changes to application plan "CheapPlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And I navigate to Invoices issued for me on 3rd June 2009
      Then I should see "EUR 12.00"

  # Scenario: change plan in 2 different months
  #   Given the buyer is signed up to application plan "CheapPlan" on 1st May 2009
  #   When I log in as "stallman" on foo.3scale.localhost on 15th May 2009
  #     And buyer "stallman" makes 1 service transactions with:
  #     | Metric | Value |
  #     | hits   |     1 |
  #   And the buyer changes to application plan "ExpensivePlan"
  #   And buyer "stallman" makes 1 service transactions with:
  #   | Metric | Value |
  #   | hits   |     1 |
  #   When I log in as "stallman" on foo.3scale.localhost on 17th May 2009
  #   And the buyer changes to application plan "CheapPlan"
  #   And buyer "stallman" makes 1 service transactions with:
  #   | Metric | Value |
  #   | hits   |     1 |
  #   And I navigate to Invoices issued for me on 3rd June 2009
  #   Then I follow "Show"
  #   Then show me the page
  #   Then I should see "EUR 12.00"

  Scenario: 2 plan changes in one month the same day POSTPAID
      Given the buyer is signed up to application plan "CheapPlan" on 14th May 2009
       And buyer "stallman" makes 1 service transactions with:
        | Metric | Value |
        | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost on 15th May 2009
       And buyer "stallman" makes 1 service transactions with:
        | Metric | Value |
        | hits   |     1 |
      And the buyer changes to application plan "ExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And the buyer changes to application plan "VeryExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And I navigate to Invoices issued for me on 3rd June 2009
      Then I follow "Show"
      Then I should see "EUR 301.00"

  Scenario: 2 plan changes in one month in 2 consecutive days POSTPAID
      Given the buyer is signed up to application plan "CheapPlan" on 14th May 2009
       And buyer "stallman" makes 1 service transactions with:
        | Metric | Value |
        | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost on 15th May 2009
       And the buyer changes to application plan "ExpensivePlan"
       And buyer "stallman" makes 1 service transactions with:
        | Metric | Value |
        | hits   |     1 |
      When I log in as "stallman" on foo.3scale.localhost on 16th May 2009
      And the buyer changes to application plan "VeryExpensivePlan"
      And buyer "stallman" makes 1 service transactions with:
      | Metric | Value |
      | hits   |     1 |
      And I navigate to Invoices issued for me on 3rd June 2009
      Then I follow "Show"
      Then I should see "EUR 111.00"
