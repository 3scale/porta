@stats
Feature: Change plan
  In order to adapt to my changing requirements
  As a buyer
  I want to upgrade or downgrade my plan

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch visible
    Given an application plan "FreeAsInBeer" of provider "foo.example.com" for 0 monthly
      And an application plan "PaidAsInLunch" of provider "foo.example.com" for 31 monthly
      And an application plan "PaidAsInDiplomat" of provider "foo.example.com" for 3100 monthly
    Given the current domain is foo.example.com

  Scenario: Change without billed cost
      Given the time is 5th May 2009
        And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 5th May 2009

       When I log in as "stallman" on foo.example.com
        And I change application plan to "PaidAsInDiplomat" on 15th May 2009 UTC
        And time flies to 3rd June 2009
        And I navigate to invoice issued for me in "May, 2009"
       Then I should see line items
        | name                           | quantity | cost     |
        | Fixed fee ('PaidAsInLunch')    |          | 27.00    |
        | Refund ('PaidAsInLunch')       |          | -17.00   |
        | Fixed fee ('PaidAsInDiplomat') |          | 1,700.00 |
        | Total cost                     |          | 1,710.00 |

  Scenario: Should not refund but bill upgrade on PREPAID billing
      Given the time is 25th April 2009
        And provider "foo.example.com" has prepaid billing enabled
        And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 25th April 2009

       When I log in as "stallman" on foo.example.com
        And I change application plan to "PaidAsInDiplomat" on 15th May 2009 UTC
        And time flies to 3rd June 2009
        And I navigate to 2nd invoice issued for me in "May, 2009"
       Then I should see line items
         | name                                            | description                                              | quantity   |     cost |
         | Refund ('PaidAsInLunch')                        | May 15, 2009 ( 0:00) - May 31, 2009 (23:59)              |        1   |   -17.00 |
         | Application upgrade ('PaidAsInLunch' to 'PaidAsInDiplomat')  | May 15, 2009 ( 0:00) - May 31, 2009 (23:59) |        1   | 1,700.00 |
         | Total cost                                      |                                                          |            | 1,683.00 |

  Scenario: Paying a fee without change plan POSTPAID
    Given the time is 28th April 2009
      And provider "foo.example.com" is charging
      And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 28th April 2009
    When I log in as "stallman" on foo.example.com on 15th June 2009
     And I navigate to 1st invoice issued for me in "May, 2009"
     Then I should see line items
         | name                         | description                                 | quantity |  cost |
         | Fixed fee ('PaidAsInLunch')  | May 1, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 31.00 |
         | Total cost                   |                                             |          | 31.00 |


  Scenario: Trial period ends and no change plan POSTPAID
    Given plan "PaidAsInLunch" has trial period of 5 days
      And provider "foo.example.com" is charging
    Given the time is 30 April 2009
      And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 30th April 2009
      When time flies to 3rd June 2009
       And I log in as "stallman" on foo.example.com on 3rd June 2009
       And I navigate to invoice issued for me in "May, 2009"
    Then I should see line items
         | name                         | description                                 | quantity |  cost |
         | Fixed fee ('PaidAsInLunch')  | May 5, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 27.00 |
         | Total cost                   |                                             |          | 27.00 |

  Scenario: Change on trial causes no billing
    Given plan "PaidAsInLunch" has trial period of 15 days
      And provider "foo.example.com" is charging
      And pricing rules on plan "PaidAsInLunch":
      | Metric | Cost per unit | Min | Max      |
      | hits   |           0.1 |   1 | infinity |
      And pricing rules on plan "PaidAsInDiplomat":
      | Metric | Cost per unit | Min | Max      |
      | hits   |            10 |   1 | infinity |

      # This should be ignored (trial period)
      When the time is 30 April 2009
      And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 30th April 2009
      And buyer "stallman" makes 1 service transaction with:
        | Metric | Value |
        | hits   |     3 |

      # This should be ignored (different plan but still in trial period)
      And I log in as "stallman" on foo.example.com on 10th May 2009
      And I change application plan to "PaidAsInDiplomat"
      And buyer "stallman" makes 1 service transaction with:
        | Metric | Value |
        | hits   |     5 |

      # This should be billed
      And time flies to 16th May 2009
      And buyer "stallman" makes 1 service transaction with:
        | Metric | Value |
        | hits   |     7 |

      And time flies to 10st June 2009
      And I navigate to invoice issued for me in "May, 2009"
      Then I should see line items
         | name                             | description                                 | quantity | cost  |
         | Fixed fee ('PaidAsInDiplomat')   | May 15, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 1,700 |
         | Hits                             | May 15, 2009 ( 0:00) - May 31, 2009 (23:59) |        7 | 70    |
         | Total cost                       |                                             |          | 1,770 |
