@stats @javascript
Feature: All kind of contracts are billed
  In order to have flexibility in billing operations
  As a provider
  I want to be bill account, service and application contracts separately

  Background:
    Given a provider with billing and finance enabled
    And the provider has one buyer
    And the provider has a paid application plan "Application Plan" of 100 per month
    And the provider has a paid service plan "Service Plan" of 31 per month
    And the provider has a paid account plan "Account Plan" of 1 per month

  Scenario: Monthly fee on application plan (no billable contracts)
    Given all the rolling updates features are off
    And the date is 1st January 2009
    And the buyer signed up for provider's paid application plan
    And the buyer's application plan contract is pending
    When time flies to 3rd March 2009

    Then the buyer should have following line items for "January, 2009" invoice:
      | name                              | quantity |  cost    |
      | Fixed fee ('Application Plan')    |          | 100.00   |
      | Total cost                        |          | 100.00   |


  Scenario: Monthly fee on account plan (no billable contracts)
    Given all the rolling updates features are off
    And the date is 1st January 2009
    And the buyer signed up for provider's paid account plan
    And the buyer's account plan contract is pending
    When time flies to 3rd March 2009

    Then the buyer should have following line items for "January, 2009" invoice:
      | name                          | quantity |  cost  |
      | Fixed fee ('Account Plan')    |          | 1.00   |
      | Total cost                    |          | 1.00   |


  Scenario: Monthly fee on service plan (no billable contracts)
    Given all the rolling updates features are off
    And the date is 1st January 2009
    And the buyer signed up for provider's paid service plan
    And the buyer's service plan contract is pending
    When time flies to 3rd March 2009

    Then the buyer should have following line items for "January, 2009" invoice:
      | name                          | quantity |  cost  |
      | Fixed fee ('Service Plan')    |          | 31.00  |
      | Total cost                    |          | 31.00  |


  ### Billable contracts enabled

  Scenario: Monthly fee on application plan (with billable contracts)
    Given all the rolling updates features are off
    And I have billable_contracts feature enabled
    And the date is 1st January 2009
    And the buyer signed up for provider's paid application plan
    And the buyer's application plan contract is pending
    When time flies to 3rd March 2009
    Then the buyer should have 0 invoice

  Scenario: Monthly fee on account plan (with billable contracts)
    Given all the rolling updates features are off
    And I have billable_contracts feature enabled
    And the date is 1st January 2009
    And the buyer signed up for provider's paid account plan
    And the buyer's account plan contract is pending
    When time flies to 3rd March 2009
    Then the buyer should have 0 invoice

  Scenario: Monthly fee on service plan (with billable contracts)
    Given all the rolling updates features are off
    And I have billable_contracts feature enabled
    And the date is 1st January 2009
    And the buyer signed up for provider's paid service plan
    And the buyer's service plan contract is pending
    When time flies to 3rd March 2009
    Then the buyer should have 0 invoice

  Scenario: Monthly fee: contracts activated in middle of month. With billable contracts
    Given all the rolling updates features are off
    And I have billable_contracts feature enabled
    And the date is 1st January 2009
    And the buyer signed up for provider's paid service plan
    And the buyer's service plan contract is pending
    When time flies to 15th January 2009
    And the provider accepts the buyer's service plan contract
    When time flies to 3rd March 2009
    Then the buyer should have following line items for "January, 2009" invoice:
      | name                              | quantity |  cost      |
      | Fixed fee ('Service Plan')        |          | 17.00      |
      | Total cost                        |          | 17.00      |
    Then the buyer should have following line items for "February, 2009" invoice:
      | name                              | quantity |  cost      |
      | Fixed fee ('Service Plan')        |          | 31.00      |
      | Total cost                        |          | 31.00      |

  Scenario: Monthly fee: contracts activated in middle of month. Without billable contracts feature
    Given all the rolling updates features are off
    And the date is 1st January 2009
    And the buyer signed up for provider's paid service plan
    And the buyer's service plan contract is pending
    When time flies to 15th January 2009
    And the provider accepts the buyer's service plan contract
    When time flies to 3rd March 2009
    Then the buyer should have following line items for "January, 2009" invoice:
      | name                              | quantity |  cost      |
      | Fixed fee ('Service Plan')        |          | 31.00      |
      | Total cost                        |          | 31.00      |
    Then the buyer should have following line items for "February, 2009" invoice:
      | name                              | quantity |  cost      |
      | Fixed fee ('Service Plan')        |          | 31.00      |
      | Total cost                        |          | 31.00      |

  Scenario: Monthly fee prorated with contract subscribed in the middle of the month
    Given all the rolling updates features are off
    And the date is 15th January 2009
    And the buyer signed up for provider's paid service plan
    And the buyer's service plan contract is live
    When time flies to 3rd March 2009
    Then the buyer should have following line items for "January, 2009" invoice:
      | name                              | quantity |  cost    |
      | Fixed fee ('Service Plan')        |          | 17.00    |
      | Total cost                        |          | 17.00    |
    Then the buyer should have following line items for "February, 2009" invoice:
      | name                              | quantity |  cost    |
      | Fixed fee ('Service Plan')        |          | 31.00    |
      | Total cost                        |          | 31.00    |

