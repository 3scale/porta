# TODO: to be cleaned up / refactored
@stats
Feature: Automatic billing with plan changes on POSTPAID
  As a provider I want to differentiate costs added by the automatic
  billing job and my manually created invoices

  Background:
    Given a provider on 1st January 2017
    And the default product of the provider has name "My API"
    And the provider is charging its buyers in postpaid mode
    And the provider has "finance" visible
    Given the provider service allows to change application plan directly
    And a buyer "Bob Buyer"
    And the following application plans:
      | Product | Name      | Cost per month |
      | My API  | Paid      | 31             |
      | My API  | Expensive | 3100           |

  Scenario: Monthly fee on application plan upgrading the same day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer is signed up to plan "Paid"
    Then the buyer changes to application plan "Expensive"
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
    And the buyer is signed up to plan "Expensive"
    Then the buyer changes to application plan "Paid"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                        | quantity |   cost    |
      | Fixed fee ('Expensive')     |          |  3,100.00 |
      | Refund ('Expensive')        |          | -3,100.00 |
      | Fixed fee ('Paid')          |          |     31.00 |
      | Total cost                  |          |     31.00 |

  Scenario: Monthly fee on application plan downgrading in the middle of the same day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer is signed up to plan "Expensive"
    And the date is 1st January 2017 12:00
    Then the buyer changes to application plan "Paid"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                        | quantity |   cost    |
      | Fixed fee ('Expensive')     |          |  3,100.00 |
      | Refund ('Expensive')        |          | -3,050.00 |
      | Fixed fee ('Paid')          |          |     30.50 |
      | Total cost                  |          |     80.50 |

  Scenario: Monthly fee on application plan downgrading on different day
    Given all the rolling updates features are off
    And the date is 1st January 2017 UTC
    And the buyer is signed up to plan "Expensive"
    And time flies to 2nd January 2017
    Then the buyer changes to application plan "Paid"
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
    And the following application plans:
      | Product | Name            | Cost per month |
      | My API  | ExpensiveAsHell | 310000         |
    And the date is 1st January 2017
    And the buyer is signed up to plan "Paid"
    And time flies to 2nd January 2017
    Then the buyer changes to application plan "Expensive"
    And time flies to 3rd January 2017
    Then the buyer changes to application plan "ExpensiveAsHell"
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
    And the buyer is signed up to plan "Paid"
    And time flies to 2nd January 2017
    Then I create a new invoice from the API for this buyer for January, 2017 with:
      | name                        |  cost      |
      | Custom support              |    200.00  |

    Then the buyer changes to application plan "Expensive"
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
    And the buyer is signed up to plan "Paid"
    Then I create a new invoice from the API for this buyer for January, 2017 with:
      | name                        |  cost      |
      | Custom support              |    200.00  |

    Then the buyer changes to application plan "Expensive"
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
