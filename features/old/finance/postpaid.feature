@stats

Feature: Postpaid billing
  In order to pay only what I use
  As a buyer
  I want use the postpaid mode

Background:
  Given a provider "xyz.example.com" with billing enabled
    And provider "xyz.example.com" has "finance" switch visible
  Given a default service of provider "xyz.example.com" has name "api"
    And a metric "transfer" of provider "xyz.example.com"
    And an application plan "Variable" of provider "xyz.example.com" for 200 monthly
    And pricing rules on plan "Variable":
      | Metric   | Cost per unit | Min | Max      |
      | hits     |           0.1 |   1 | infinity |
      | transfer |           0.2 |   1 | infinity |


  Scenario: With free plan, no invoice is created
      Given an application plan "FreeAsInBeer" of provider "xyz.example.com" for 0 monthly
      And a buyer "broke" signed up to application plan "FreeAsInBeer"

      Given the time is 15th January 2009
      When buyer "broke" makes 5 service transaction with:
        | Metric   | Value |
        | hits     |     1 |
        | transfer |   120 |

      When 1 month passes
      Then the date should be 15th February 2009

      When I log in as "broke" on xyz.example.com
      And I navigate to invoices issued for me
      Then I should see 0 invoices

  Scenario: Variable only
   Given all the rolling updates features are off
   Given an application plan "PureVariable" of provider "xyz.example.com" for 0 monthly
     And pricing rules on plan "PureVariable":
      | Metric | Cost per unit | Min | Max      |
      | hits   |             1 |   1 | infinity |

     And a buyer "varnish" signed up to application plan "PureVariable" on 10th January 2009
     And buyer "varnish" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    20 |

    And I log in as "varnish" on xyz.example.com on 20th January 2009
    And I change application plan to "Variable"

    When time flies to 3rd February 2009
    And I navigate to invoice issued for me in "January, 2009"
    Then I should see line items
     | name                   | Description                                         | quantity |  cost |
     | Fixed fee ('Variable') | January 20, 2009 ( 0:00) - January 31, 2009 (23:59) |        1 | 77.42 |
     | Hits                   | January 10, 2009 ( 0:00) - January 31, 2009 (23:59) |       20 |  2.00 |
     | Total cost             |                                                     |          | 79.42 |

   When time flies to 3rd March 2009
    And I navigate to invoice issued for me in "February, 2009"
    Then I should see line items
     | name                   | quantity | cost |
     | Fixed fee ('Variable') |          |  200 |
     | Total cost             |          |  200 |


  Scenario: Variable only instant bill enabled
   Given all the rolling updates features are on
   Given an application plan "PureVariable" of provider "xyz.example.com" for 0 monthly
     And pricing rules on plan "PureVariable":
      | Metric | Cost per unit | Min | Max      |
      | hits   |             1 |   1 | infinity |

     And a buyer "varnish" signed up to application plan "PureVariable" on 10th January 2009
     And buyer "varnish" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    20 |

    And I log in as "varnish" on xyz.example.com on 20th January 2009
    And I change application plan to "Variable"

    When time flies to 3rd February 2009
    And I navigate to invoice issued for me in "January, 2009"
    Then I should see line items
     | name                   | Description                                         | quantity |  cost |
     | Hits                   | January 10, 2009 ( 0:00) - January 31, 2009 (23:59) |       20 | 20.00 |
     | Fixed fee ('Variable') | January 20, 2009 ( 0:00) - January 31, 2009 (23:59) |        1 | 77.42 |
     | Total cost             |                                                     |          | 97.42 |

   When time flies to 3rd March 2009
    And I navigate to invoice issued for me in "February, 2009"
    Then I should see line items
     | name                   | quantity | cost |
     | Fixed fee ('Variable') |          |  200 |
     | Total cost             |          |  200 |

 Scenario: Bill fixed fee in the beginning, variable in the end of the month
    Given the date is 31st December 2008
      And a buyer "tycoon" signed up to application plan "Variable"

    Given time flies to 14th January 2009
      And buyer "tycoon" makes 2 service transactions with:
        | Metric   | Value |
        | hits     |    20 |
        | transfer |     5 |

     When time flies to 3rd February 2009
     And I log in as "tycoon" on xyz.example.com
      And I navigate to invoice issued for me in "January, 2009"
     Then I should see line items
      | name                   | quantity | cost |
      | Fixed fee ('Variable') |          |  200 |
      | Hits                   |       40 |    4 |
      | transfer               |       10 |    2 |
      | Total cost             |          |  206 |

 Scenario: Buyer is not billed monthly - no invoice is created
   Given the date is 31st December 2008
     And a buyer "tycoon" signed up to application plan "Variable"
     And buyer "tycoon" is not billed monthly

    When time flies to 14th January 2009
     And buyer "tycoon" makes 2 service transactions with:
        | Metric   | Value |
        | hits     |    20 |
        | transfer |     5 |

     And time flies to 10th February 2009
     And I log in as "tycoon" on xyz.example.com
     And I navigate to invoices issued for me
    Then I should see 0 invoices
