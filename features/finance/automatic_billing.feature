@stats
Feature: Invoices creation by billing job or by API/UI
  As a provider I want to differentiate costs added by the automatic
  billing job and my manually created invoices

  Background:
    Given a provider with billing and finance enabled
    Given the provider service allows to change application plan directly
    And the provider has prepaid billing enabled
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
      | name                                            | quantity |  cost     |
      | Fixed fee ('Paid')                              |          |    31.00  |
      | Refund ('Paid')                                 |          |   -31.00  |
      | Application upgrade ('Paid' to 'Expensive')     |          | 3,100.00  |
      | Total cost                                      |          | 3,100.00  |

  Scenario: Monthly fee on application plan downgrading the same day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer signed up for plan "Expensive"
    Then the buyer changed to plan "Paid"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                                            | quantity |   cost    |
      | Fixed fee ('Expensive')                         |          |  3,100.00 |
      | Refund ('Expensive')                            |          | -3,100.00 |
      | Application upgrade ('Expensive' to 'Paid')     |          |     31.00 |
      | Total cost                                      |          |     31.00 |


  Scenario: Monthly fee on application plan downgrading on different day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer signed up for plan "Expensive"
    And time flies to 2nd January 2017
    Then the buyer changed to plan "Paid"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" invoice:
      | name                                            | quantity |   cost    |
      | Fixed fee ('Expensive')                         |          |  3,100.00 |
      | Total cost                                      |          |  3,100.00 |
    And there is only one invoice for "January, 2017"

  Scenario: Monthly fee on application plan creating a new invoice manually, upgrading on different day
    Given all the rolling updates features are off
    And the date is 1st January 2017
    And the buyer signed up for plan "Paid"
    And time flies to 2nd January 2017
    Then I create a new invoice from the API for this buyer for January, 2017 with:
      | name                                            |  cost      |
      | Custom support                                  |    200.00  |

    Then the buyer changed to plan "Expensive"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" in the 1st invoice:
      | Fixed fee ('Paid')                              |          |    31.00  |
    Then the buyer should have following line items for "January, 2017" in the 2nd invoice:
      | name                                            | quantity |  cost     |
      | Custom support                                  |          |   200.00  |
      | Total cost                                      |          |   200.00  |
    Then the buyer should have following line items for "January, 2017" in the 3rd invoice:
      | name                                            | quantity |  cost     |
      | Refund ('Paid')                                 |          |   -30.00  |
      | Application upgrade ('Paid' to 'Expensive')     |          | 3,000.00  |
      | Total cost                                      |          | 2,970.00  |
    Then the buyer should have following line items for "February, 2017" in the 1st invoice:
      | Fixed fee ('Paid')                              |          | 3,100.00  |


  Scenario: Monthly fee on application plan upgrading the same day and a manual invoice was created
    Given all the rolling updates features are off
    And the date is 1st January 2017 UTC
    And the buyer signed up for plan "Paid"
    Then I create a new invoice from the API for this buyer for January, 2017 with:
      | name                                            |  cost      |
      | Custom support                                  |    200.00  |

    Then the buyer changed to plan "Expensive"
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" in the 1st invoice:
      | name                                            | quantity |  cost     |
      | Custom support                                  |          |   200.00  |
      | Total cost                                      |          |   200.00  |
    Then the buyer should have following line items for "January, 2017" in the 2nd invoice:
      | name                                            | quantity |  cost     |
      | Fixed fee ('Paid')                              |          |    31.00  |
      | Refund ('Paid')                                 |          |   -31.00  |
      | Application upgrade ('Paid' to 'Expensive')     |          | 3,100.00  |
      | Total cost                                      |          | 3,100.00  |
    Then the buyer should have following line items for "February, 2017" in the 1st invoice:
      | Fixed fee ('Paid')                              |          | 3,100.00  |

