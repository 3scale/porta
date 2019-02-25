@stats
Feature: Variable cost on automatic billing
  As a provider I want to bill for variable cost

  Background:
    Given a provider with billing and finance enabled
    Given all the rolling updates features are off
    And the provider has one buyer
    And the provider has a paid application plan "VariableOnly" of 0 per month
    And pricing rules on plan "VariableOnly":
      | Metric   | Cost per unit | Min   | Max      |
      | hits     |           0.1 |     1 | infinity |

  Scenario: Variable cost in the middle of the first month of a contract subscribed days before
    Given the buyer signed up for plan "VariableOnly" on 10th January 2019
    And time flies to 15th January 2019
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    When time flies to 3rd February 2019
    Then the buyer should have following line items for "January, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      400 |    40.00  |
      | Total cost                  |          |    40.00  |

  Scenario: Variable cost in the middle of the first month of a contract subscribed on the same day
    Given the buyer signed up for plan "VariableOnly" on 10th January 2019
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    When time flies to 3rd February 2019
    Then the buyer should have following line items for "January, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      400 |    40.00  |
      | Total cost                  |          |    40.00  |

  Scenario: Variable cost on the first day of the month of a new contract
    Given the buyer signed up for plan "VariableOnly" on 1st January 2019
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    When time flies to 3rd February 2019
    Then the buyer should have following line items for "January, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      400 |    40.00  |
      | Total cost                  |          |    40.00  |

  Scenario: Variable cost on the last day of the first month of a contract subscribed days before that
    Given the buyer signed up for plan "VariableOnly" on 10th January 2019
    And time flies to 31st January 2019
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    When time flies to 3rd February 2019
    Then the buyer should have following line items for "January, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      400 |    40.00  |
      | Total cost                  |          |    40.00  |

  Scenario: Variable cost on the last day of the first month of a contract subscribed on the same day
    Given the buyer signed up for plan "VariableOnly" on 31st January 2019
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    When time flies to 3rd February 2019
    Then the buyer should have following line items for "January, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      400 |    40.00  |
      | Total cost                  |          |    40.00  |

  Scenario: Variable cost on the last day of the first month of a contract subscribed on the same day and other months
    Given the buyer signed up for plan "VariableOnly" on 31st January 2019
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    And time flies to 1st February 2019
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    500 |
    When time flies to 3rd March 2019
    Then the buyer should have following line items for "January, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      400 |    40.00  |
      | Total cost                  |          |    40.00  |
    Then the buyer should have following line items for "February, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      500 |    50.00  |
      | Total cost                  |          |    50.00  |

  Scenario: Variable cost in automated billing is always UTC
    Given the provider time zone is "Pacific Time (US & Canada)"
    And the buyer signed up for plan "VariableOnly" on 31st January 2019 22:00 PST
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    400 |
    And time flies to 1st February 2019 12:00 PST
    And the buyer makes a service transactions with:
      | Metric   | Value  |
      | hits     |    500 |
    When time flies to 3rd March 2019
    Then the buyer should have following line items for "February, 2019" invoice:
      | name                        | quantity |  cost     |
      | Hits                        |      900 |    90.00  |
      | Total cost                  |          |    90.00  |
