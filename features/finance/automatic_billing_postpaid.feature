@stats
Feature: Automatic billing with plan changes on POSTPAID
  As a provider I want to differentiate costs added by the automatic
  billing job and my manually created invoices

  Background:
    Given a provider with billing and finance enabled
    Given the provider service allows to change application plan directly
    And the provider has one buyer
    And the provider has a paid application plan "Paid" of 31 per month
    And the provider has another paid application plan "Expensive" of 3100 per month

  Scenario: Monthly fee on application plan upgrading the same day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer signed up for plan "Paid"
    Then the buyer changed to plan "Expensive"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                        | quantity |  cost     |
      | Fixed fee ('Paid')          |          |    31.00  |
      | Refund ('Paid')             |          |   -31.00  |
      | Fixed fee ('Expensive')     |          | 3,100.00  |
      | Total cost                  |          | 3,100.00  |

  Scenario: Monthly fee on application plan downgrading the same day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer signed up for plan "Expensive"
    Then the buyer changed to plan "Paid"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                        | quantity |   cost    |
      | Fixed fee ('Expensive')     |          |  3,100.00 |
      | Refund ('Expensive')        |          | -3,100.00 |
      | Fixed fee ('Paid')          |          |     31.00 |
      | Total cost                  |          |     31.00 |

  Scenario: Monthly fee on application plan downgrading on different day
    Given all the rolling updates features are off
    And the date is 1st January 2017 UTC
    And the buyer signed up for plan "Expensive"
    And time flies to 2nd January 2017
    Then the buyer changed to plan "Paid"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                        | quantity |   cost    |
      | Fixed fee ('Expensive')     |          |  3,100.00 |
      | Refund ('Expensive')        |          | -3,000.00 |
      | Fixed fee ('Paid')          |          |     30.00 |
      | Total cost                  |          |    130.00 |
    And there is only one invoice for "January, 2017"

  Scenario: Monthly fee on several application plan upgrades in the middle of the month
    Given all the rolling updates features are off
    And the provider has a third paid application plan "ExpensiveAsHell" of 310000 per month
    And the date is 1st January 2017 UTC
    And the buyer signed up for plan "Paid"
    And time flies to 2nd January 2017
    Then the buyer changed to plan "Expensive"
    And time flies to 3rd January 2017
    Then the buyer changed to plan "ExpensiveAsHell"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                           | quantity |     cost    |
      | Fixed fee ('Paid')             |          |      31.00  |
      | Refund ('Paid')                |          |     -30.00  |
      | Fixed fee ('Expensive')        |          |   3,000.00  |
      | Refund ('Expensive')           |          |  -2,900.00  |
      | Fixed fee ('ExpensiveAsHell')  |          | 290,000.00  |
      | Total cost                     |          | 290,101.00  |
    And there is only one invoice for "January, 2017"

  Scenario: Monthly fee on application plan creating a new invoice manually, upgrading on different day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer signed up for plan "Paid"
    And time flies to 2nd January 2017
    Then I create a new invoice from the API for this buyer for January, 2017 with:
      | name                        |  cost      |
      | Custom support              |    200.00  |

    Then the buyer changed to plan "Expensive"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" in the 1st invoice:
      | name                        | quantity |  cost     |
      | Fixed fee ('Paid')          |          |    31.00  |
      | Refund ('Paid')             |          |   -30.00  |
      | Fixed fee ('Expensive')     |          | 3,000.00  |
      | Total cost                  |          | 3,001.00  |
    Then the buyer should have following line items for "January, 2017" in the 2nd invoice:
      | name                        | quantity |  cost     |
      | Custom support              |          |   200.00  |
      | Total cost                  |          |   200.00  |

  Scenario: Monthly fee on application plan upgrading the same day and a manual invoice was created
    Given all the rolling updates features are off
    And the date is 1st January 2017 UTC
    And the buyer signed up for plan "Paid"
    Then I create a new invoice from the API for this buyer for January, 2017 with:
      | name                        |  cost      |
      | Custom support              |    200.00  |

    Then the buyer changed to plan "Expensive"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" in the 1st invoice:
      | name                        | quantity |  cost     |
      | Custom support              |          |   200.00  |
      | Total cost                  |          |   200.00  |
    Then the buyer should have following line items for "January, 2017" in the 2nd invoice:
      | name                        | quantity |  cost     |
      | Fixed fee ('Paid')          |          |    31.00  |
      | Refund ('Paid')             |          |   -31.00  |
      | Fixed fee ('Expensive')     |          | 3,100.00  |
      | Total cost                  |          | 3,100.00  |
