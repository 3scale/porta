Feature: Prepaid billing of a buyer
  In order to pre-pay the service
  As a buyer
  I want to be charged as soon as possible

 Background:
  Given a provider "foo.example.com" with prepaid billing enabled
    And provider "foo.example.com" has "finance" switch visible
    And an application plan "Fixed" of provider "foo.example.com" for 200 monthly
    And an application plan "Variable" of provider "foo.example.com" for 200 monthly
    And pricing rules on plan "Variable":
      | Metric   | Cost per unit | Min | Max      |
      | hits     |           0.1 |   1 | infinity |


 Scenario: Bill one month beforehand
  Given the date is 1st January 2009
   When a buyer "zoidberg" signed up to application plan "Fixed" on 1st January 2009
    And I log in as "zoidberg" on foo.example.com

  Given the time flies to 3rd February 2009
   Then I should have 2 invoices
    And I see my invoice from "January, 2009" is "Pending"

   When I navigate to invoice issued for me in "February, 2009"
   Then I should see line items
    | name                | description                                           | quantity |   cost |
    | Fixed fee ('Fixed') | February 1, 2009 ( 0:00) - February 28, 2009 (23:59) |        1 | 200.00 |
    | Total cost          |                                                       |          | 200.00 |


 @stats
 Scenario: Prepaid and variable billing
   Given the time is 5th February 2009
     And a buyer "zoidberg" signed up to application plan "Variable" on 5th February 2009

   # FIXME: does not work when the hit is made on 5th - BUG or FEATURE?
   Given the time flies to 6th February 2009
     And buyer "zoidberg" makes 1 service transactions with:
        | Metric   | Value |
        | hits     |    40 |

   Given the time flies to 5th March 2009
     And I log in as "zoidberg" on foo.example.com

      When I navigate to 1st invoice issued for me in "February, 2009"
      Then I should see invoice in state "Pending"
       And I should see line items
        | name                   | description                                           | quantity |   cost |
        | Fixed fee ('Variable') | February 5, 2009 ( 0:00) - February 28, 2009 (23:59) |        1 | 171.43 |

      When I navigate to invoice issued for me in "March, 2009"
      Then I should see invoice in state "Pending"
       And I should see line items
        | name                   | description                                           | quantity |   cost |
        | Fixed fee ('Variable') | March 1, 2009 ( 0:00) - March 31, 2009 (23:59)       |        1 | 200.00 |
        | Hits                   | February 5, 2009 ( 0:00) - February 28, 2009 (23:59) |       40 |   4.00 |
        | Total cost             |                                                       |          | 204.00 |


 Scenario: Bill and issue when the trial ends, charge when due
  Given the date is 1st January 2009
    And plan "Fixed" has trial period of 15 days
    And provider "foo.example.com" is fake charging
    And provider "foo.example.com" has valid payment gateway

   When a buyer "zoidberg" signed up to application plan "Fixed" on 1st January 2009
    And I log in as "zoidberg" on foo.example.com

   Then I should have 1 invoice on 20th January 2009
    And I see my invoice from "January, 2009" is "Pending"

   Then I should have 1 invoice on 23th January 2009
    And I see my invoice from "January, 2009" is "Unpaid"

   Given buyer "zoidberg" has valid credit card
   Then I should have 1 invoice on 24th January 2009
    And I see my invoice from "January, 2009" is "Paid"



 Scenario: Prepaid with setup fee and no trial period
  Given the date is 1st January 2009
    And plan "Fixed" has trial period of 0 days
    And plan "Fixed" has setup fee of 210
    And a buyer "zoidberg" signed up to application plan "Fixed" on 1st January 2009
    And I log in as "zoidberg" on foo.example.com

   When the time flies to 4th January 2009
    And I navigate to invoices issued for me
   Then I see my invoice from "January, 2009" is "Pending"

   When I navigate to invoice issued for me in "January, 2009"
   Then I should see line items
    | name                |   cost |
    | Fixed fee ('Fixed') |    200 |
    | Setup fee ('Fixed') | 210.00 |
    | Total cost          |    410 |
