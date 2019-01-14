@stats
Feature: Instant biling plan change feature
  As a provider I want to charge the variable cost on plan change

  Background:
    Given a provider with billing and finance enabled
    Given the provider service allows to change application plan directly
    And the provider has prepaid billing enabled
    Given all the rolling updates features are off
    And I have instant_bill_plan_change feature enabled
    And the provider has one buyer

  Scenario: Charging variable cost on plan change
    Given the provider has a paid application plan "NoVariable" of 31 per month
    And the provider has another paid application plan "WithVariable" of 310 per month
    And pricing rules on plan "WithVariable":
      | Metric   | Cost per unit | Min    | Max      |
      | hits     |           0.1 |   100 | infinity |

    And the date is 1st January 2017
    And the buyer signed up for plan "NoVariable"
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    When time flies to 3rd January 2017
    And the buyer changed to plan "WithVariable"
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |   1000 |
    When time flies to 4th January 2017
    And the buyer changed to plan "NoVariable"
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |   5000 |

    When time flies to 6th January 2017
    And the buyer changed to plan "WithVariable"
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |   2000 |
    When time flies to 3rd February 2017

    Then the buyer should have following line items for "January, 2017" in the 1st invoice:
      | name                                                    | quantity |  cost     |
      | Fixed fee ('NoVariable')                                |          |     31.00 |
      | Total cost                                              |          |     31.00 |

    # Upgrading can be done
    # Not charging NoVariable variable cost (there is none)
    And the buyer should have following line items for "January, 2017" in the 2nd invoice:
      | name                                                    | quantity |  cost     |
      | Refund ('NoVariable')                                   |          |    -29.00 |
      | Application upgrade ('NoVariable' to 'WithVariable')    |          |    290.00 |
      | Total cost                                              |          |    261.00 |

    # FIXME: Downgrading will not refund as it will `result` in negative invoice for fixed fee
    # but actually the total (fixed + variable) > 0
    # This is a case we need to solve with negative invoices

    And the buyer should have following line items for "January, 2017" in the 3rd invoice:
      | name                                                    | quantity |  cost     |
      | Hits                                                    |     1000 |     90.10 |
      | Total cost                                              |          |     90.10 |

    And the buyer should have following line items for "February, 2017" invoice:
      | name                                                    | quantity |  cost     |
      | Fixed fee ('WithVariable')                              |          |    310.00 |
      | Hits                                                    |     2000 |    190.10 |
      | Total cost                                              |          |    500.10 |

  Scenario: Billing variable cost on plan change after multiple billing cycles without reaching the threshold
    Given the provider has a paid application plan "PureVariable" of 0 per month
    And the provider has another paid application plan "PureVariable101" of 0 per month
    And pricing rules on plan "PureVariable":
      | Metric   | Cost per unit | Min   | Max      |
      | hits     |           0.1 |     1 | infinity |
    And pricing rules on plan "PureVariable101":
      | Metric   | Cost per unit | Min   | Max      |
      | hits     |           0.1 |   101 | infinity |

    # In March, 2018
    Given the buyer signed up for plan "PureVariable101" on 20th Mar 2018
    And the buyer makes a service transactions with:
      | Metric | Value |
      | hits   |    50 |
    When time flies to 3rd Apr 2018
    # Automatic billing ran, threshold wasn't reached in the past month
    Then the buyer should have 0 invoices

    # In April, 2018
    Given the buyer makes a service transactions with:
      | Metric | Value |
      | hits   |    65 |
    When time flies to 3rd May 2018
    # Automatic billing ran, threshold wasn't reached in the past month
    Then the buyer should have 0 invoices

    # In May, 2018
    Given the buyer makes a service transactions with:
      | Metric | Value |
      | hits   |   500 |
    When time flies to 4th May 2018
    And the buyer changed to plan "PureVariable"
    When time flies to 7th May 2018
    # Plan changed occurred, threshold of PureVariable101 was reached
    Then the buyer should have following line items for "May, 2018" in the 1st invoice:
      | name            | quantity |  cost     |
      | Hits            |      500 |     40.00 |
      | Total cost      |          |     40.00 |
    And the buyer makes a service transactions with:
      | Metric | Value  |
      | hits   |    100 |
    When time flies to 3rd Jun 2018
    # Automatic billing ran, more accountable traffic while in PureVariable
    Then the buyer should have following line items for "June, 2018" in the 1st invoice:
      | name            | quantity |  cost     |
      | Hits            |      100 |     10.00 |
      | Total cost      |          |     10.00 |


  Scenario: Billing variable cost with multiple plan changes within a month
    Given the provider has a free application plan "FreePlan"
    And the provider has a paid application plan "PureVariable" of 0 per month
    And the provider has another paid application plan "PureVariable101" of 0 per month
    And pricing rules on plan "PureVariable":
      | Metric   | Cost per unit | Min   | Max      |
      | hits     |           0.1 |     1 | infinity |
    And pricing rules on plan "PureVariable101":
      | Metric   | Cost per unit | Min   | Max      |
      | hits     |           0.1 |   101 | infinity |

    Given the buyer signed up for plan "PureVariable" on 1st May 2018
    And the buyer makes a service transactions with:
      | Metric | Value |
      | hits   |    50 |
    When time flies to 4th May 2018
    And the buyer changed to plan "PureVariable101"
    When time flies to 7th May 2018
    # Plan changed occurred, accountable traffic while in PureVariable
    Then the buyer should have following line items for "May, 2018" in the 1st invoice:
      | name            | quantity |  cost     |
      | Hits            |       50 |      5.00 |
      | Total cost      |          |      5.00 |
    And the buyer makes a service transactions with:
      | Metric | Value |
      | hits   |    80 |
    When time flies to 8th May 2018
    And the buyer changed to plan "FreePlan"
    When time flies to 11th May 2018
    # Plan changed occurred, threshold of PureVariable101 wasn't reached
    Then the buyer should have 1 invoices
    And the buyer makes a service transactions with:
      | Metric | Value |
      | hits   |   500 |
    When time flies to 15th May 2018
    And the buyer changed to plan "PureVariable"
    When time flies to 18th May 2018
    # Plan changed occurred, nothing to bill since it was on free plan
    Then the buyer should have 1 invoices
    And the buyer makes a service transactions with:
      | Metric | Value |
      | hits   |   300 |
    When time flies to 19th May 2018
    And the buyer changed to plan "FreePlan"
    When time flies to 22th May 2018
    # Plan changed occurred, accountable traffic while in PureVariable
    Then the buyer should have following line items for "May, 2018" in the 2nd invoice:
      | name            | quantity |  cost     |
      | Hits            |      300 |     30.00 |
      | Total cost      |          |     30.00 |
