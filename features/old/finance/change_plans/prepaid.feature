Feature: Change plan prepaid
  In order to adapt to my changing requirements
  As a buyer
  I want to upgrade or downgrade my plan

  Background:
    Given a provider exists on 1st May 2009
      And the provider is charging its buyers in prepaid mode
      And provider "foo.3scale.localhost" has "finance" switch visible
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name             | Cost per month |
      | My API  | FreeAsInBeer     | 0              |
      | My API  | PaidAsInLunch    | 31             |
      | My API  | PaidAsInDiplomat | 3100           |
    Given the current domain is foo.3scale.localhost
    And a buyer "stallman"

  @commit-transactions
  Scenario: Paying a fee without change plan PREPAID
    Given the time is 1st May 2009
      And the buyer is signed up to application plan "PaidAsInLunch" on 1st May 2009
    When I log in as "stallman" on foo.3scale.localhost on 3rd June 2009
     And I navigate to 1st invoice issued for me in "May, 2009"
     Then I should see line items
         | name                         | description                                 | quantity |  cost |
         | Fixed fee ('PaidAsInLunch')  | May 1, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 31.00 |
         | Total cost                   |                                             |          | 31.00 |

  @commit-transactions
  Scenario: Trial period ends and no change plan PREPAID
    Given plan "PaidAsInLunch" has a trial period of 5 days
    Given the time is 1st May 2009
      And the buyer is signed up to application plan "PaidAsInLunch" on 1st May 2009
      When time flies to 3rd June 2009
      When I log in as "stallman" on foo.3scale.localhost on 3rd June 2009

       And I navigate to 1st invoice issued for me in "May, 2009"
    Then I should see line items
         | name                         | description                                 | quantity |  cost |
         | Fixed fee ('PaidAsInLunch')  | May 6, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 26.00 |
         | Total cost                   |                                             |          | 26.00 |


  @stats
  Scenario: Plan changes at 10th May 12:00 AM UTC PREPAID
    Given the time is 1st May 2009
      And the buyer is signed up to application plan "PaidAsInLunch" on 1st May 2009
      And I log in as "stallman" on foo.3scale.localhost
      And the buyer changes to application plan "PaidAsInDiplomat" on 10th May 2009 12:00 UTC
      When time flies to 3rd June
     And I navigate to 1st invoice issued for me in "May, 2009"
    Then I should see line items

         | name                                            | description                                 | quantity | cost     |
         | Fixed fee ('PaidAsInLunch')                     | May 1, 2009 ( 0:00) - May 31, 2009 (23:59) |        1 | 31.00    |
         | Total cost                                      |                                             |          | 31.00 |

    And I navigate to 2nd invoice issued for me in "May, 2009"
   Then I should see line items
   | name                                            | description                                 | quantity | cost     |
   | Refund ('PaidAsInLunch')                        | May 10, 2009 (12:00) - May 31, 2009 (23:59)              |        1   |   -21.50 |
   | Application upgrade ('PaidAsInLunch' to 'PaidAsInDiplomat') | May 10, 2009 (12:00) - May 31, 2009 (23:59) |        1 | 2,150.00 |
   | Total cost                                      |                                             |          | 2,128.50 |
