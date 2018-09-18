@stats
Feature: On paid plans
  In order to charge my customers
  As a provider
  I want to charge my customers the right amounts even if there is a free trial

  Background:
    Given a provider "planet.express.com" with billing enabled
      And provider "planet.express.com" is charging
      And provider "planet.express.com" has "finance" switch visible
      Given an application plan "Rocket" of provider "planet.express.com"

  Scenario: I have to pay monthly and setup fee when the trial is over
    Given the date is 23rd November 1989
      And plan "Rocket" has setup fee of 210
      And plan "Rocket" has monthly fee of 31
      And plan "Rocket" has trial period of 15 days
      And a buyer "zoidberg" signed up to application plan "Rocket"

     When 10 days pass
      And buyer "zoidberg" makes 5 service transaction with:
        | Metric | Value |
        | hits   |    10 |
      And I log in as "zoidberg" on planet.express.com
     Then I should have 0 invoices
     And I navigate to invoices issued for me

     When 6 days pass
     And I log in as "zoidberg" on planet.express.com
     Then I should have 0 invoices

     When 25 days pass
      And I navigate to invoices issued for me
     Then I should not see "November, 1989"
      And I should see "December, 1989"

     When I navigate to invoice issued for me in "December, 1989"
     Then I should see line items
     | name                           | cost |
     | Fixed fee ('Rocket')           |   24 |
     | Setup fee ('Rocket')           |  210 |
     | Total cost                     |  234 |


  Scenario: I have to pay variable fees only for transactions that happen after trial
    Given pricing rules on plan "Rocket":
      | Metric | Cost per unit | Min | Max      |
      | hits   |             1 |   1 | infinity |
    And plan "Rocket" has monthly fee of 30

    When the date is 1st November 1989
      And plan "Rocket" has trial period of 20 days
      And a buyer "zoidberg" signed up to application plan "Rocket"

    When 10 days pass
      And buyer "zoidberg" makes 5 service transaction with:
        | Metric | Value |
        | hits   |    10 |
      And I log in as "zoidberg" on planet.express.com
    Then I should have 0 invoices

    When buyer "zoidberg" makes 5 service transaction with:
        | Metric | Value |
        | hits   |    10 |
      And 11 days pass
      And I log in as "zoidberg" on planet.express.com
      Then I should have 0 invoices

     When buyer "zoidberg" makes 5 service transaction with:
        | Metric | Value |
        | hits   |    10 |

    When time flies to 1st of December, 1989
       Then I should have 0 invoices
    When 3 days pass
      Then I should have 1 invoice
    And I navigate to invoice issued for me in "November, 1989"
     Then I should see line items
     | name                 | cost |
     | Fixed fee ('Rocket') |   10 |
     | Hits                 |   50 |
     | Total cost           |   60 |

    When time flies to 1st of January, 1990
      Then I should have 1 invoice
    When 3 days pass
      Then I should have 2 invoices
    And I navigate to invoice issued for me in "December, 1989"
     Then I should see line items
     | name                 | cost |
     | Fixed fee ('Rocket') |   30 |
     | Total cost           |   30 |
