Feature: Change plan
  In order to adapt to my changing requirements
  As a buyer
  I want to upgrade or downgrade my plan

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch visible
    Given an application plan "FreeAsInBeer" of provider "foo.example.com" for 0 monthly
      And an application plan "PaidAsInLunch" of provider "foo.example.com" for 31000000 monthly
      And an application plan "PaidAsInDiplomat" of provider "foo.example.com" for 3100000000 monthly
    Given the current domain is foo.example.com

  @commit-transactions
  Scenario: Paying a fee without change plan POSTPAID
    Given the time is 28th April 2009
      And provider "foo.example.com" is charging
      And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 28th April 2009
    When I log in as "stallman" on foo.example.com on 15th June 2009
     And I navigate to 1st invoice issued for me in "May, 2009"
     Then I should see line items
         | name                         | description                                 | quantity |  cost         |
         | Fixed fee ('PaidAsInLunch')  | May 1, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 31,000,000.00 |
         | Total cost                   |                                             |          | 31,000,000.00 |

  @commit-transactions
  Scenario: Trial period ends and no change plan POSTPAID
    Given plan "PaidAsInLunch" has trial period of 5 days
    Given the time is 1st May 2009
      And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 1st May 2009
      When time flies to 1st June 2009
      When I log in as "stallman" on foo.example.com on 15th June 2009

       And I navigate to 1st invoice issued for me in "May, 2009"
    Then I should see line items
         | name                         | description                                 | quantity |  cost         |
         | Fixed fee ('PaidAsInLunch')  | May 6, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 26,000,000.00 |
         | Total cost                   |                                             |          | 26,000,000.00 |

  @stats
  Scenario: Plan upgrade from paid to paid at 10th May 12:00 AM UTC
    Given the time is 30th April 2009
      And a buyer "stallman" signed up to application plan "PaidAsInLunch" on 30th April 2009
      And I log in as "stallman" on foo.example.com
      And I change application plan to "PaidAsInDiplomat" on 10th May 2009 12:00 UTC
      When time flies to 3rd June

       And I navigate to 1st invoice issued for me in "May, 2009"
    Then I should see line items

         | name                           | description                                 | quantity | cost             |
         | Fixed fee ('PaidAsInLunch')    | May 1, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 31,000,000.00    |
         | Refund ('PaidAsInLunch')       | May 10, 2009 (12:00) - May 31, 2009 (23:59) |        1 | -21,500,000.00   |
         | Fixed fee ('PaidAsInDiplomat') | May 10, 2009 (12:00) - May 31, 2009 (23:59) |        1 | 2,150,000,000.00 |
         | Total cost                     |                                             |          | 2,159,500,000.00 |

  @stats
  Scenario: Plan upgrade from free to paid at 10th May 12:00 AM UTC
    Given the time is 30th April 2009
      And a buyer "stallman" signed up to application plan "FreeAsInBeer" on 30th April 2009
      And I log in as "stallman" on foo.example.com
      And I change application plan to "PaidAsInDiplomat" on 10th May 2009 12:00 UTC

     When time flies to 3rd June
      And I navigate to 1st invoice issued for me in "May, 2009"
     Then I should see line items

         | name                           | description                                 | quantity | cost             |
         | Fixed fee ('PaidAsInDiplomat') | May 10, 2009 (12:00) - May 31, 2009 (23:59) |        1 | 2,150,000,000.00 |
         | Total cost                     |                                             |          | 2,150,000,000.00 |

  Scenario: Plan upgrade from free to free at 10th May 12:00 AM UTC
    Given an application plan "FreeAsInCzechBeer" of provider "foo.example.com" for 0 monthly
      And the time is 30th April 2009

    When a buyer "stallman" signed up to application plan "FreeAsInBeer" on 30th April 2009
     And I log in as "stallman" on foo.example.com
     And I change application plan to "FreeAsInCzechBeer" on 10th May 2009 12:00 UTC
     And time flies to 8th June
    Then I should have 0 invoice
