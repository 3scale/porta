@stats
Feature: All kind of contracts are billed
  In order to have flexibility in billing operations
  As a provider
  I want to be bill account, service and application contracts separately

  Background:
    Given a provider on 1st January 2009
    And the default product of the provider has name "My API"
    And the provider is charging its buyers
    And the provider has "finance" visible
    And a buyer "Bob Buyer"
    And the following application plan:
      | Product | Name             | Cost per month |
      | My API  | Application Plan | 100            |
    And the following service plan:
      | Product | Name         | Cost per month |
      | My API  | Service Plan | 31             |
    And the following account plan:
      | Issuer               | Name         | Cost per month |
      | foo.3scale.localhost | Account Plan | 1              |

  Scenario: Monthly fee on application plan (no billable contracts)
    Given all the rolling updates features are off
    And the date is 1st January 2009
    And the buyer is signed up to application plan "Application Plan"
    And the buyer plan "Application Plan" contract is pending
    When time flies to 3rd March 2009

    Then the buyer should have following line items for "January, 2009" invoice:
      | name                              | quantity |  cost    |
      | Fixed fee ('Application Plan')    |          | 100.00   |
      | Total cost                        |          | 100.00   |

  Scenario: Monthly fee on account plan (no billable contracts)
    Given all the rolling updates features are off
    And the date is 1st January 2009
    And the buyer is signed up to account plan "Account Plan"
    And the buyer plan "Account Plan" contract is pending
    When time flies to 3rd March 2009

    Then the buyer should have following line items for "January, 2009" invoice:
      | name                          | quantity |  cost  |
      | Fixed fee ('Account Plan')    |          | 1.00   |
      | Total cost                    |          | 1.00   |


  Scenario: Monthly fee on service plan (no billable contracts)
    Given all the rolling updates features are off
    And the date is 1st January 2009
    And the buyer is signed up to service plan "Service Plan"
    And the buyer plan "Service Plan" contract is pending
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
    And the buyer is signed up to application plan "Application Plan"
    And the buyer plan "Application Plan" contract is pending
    When time flies to 3rd March 2009
    Then the buyer should have 0 invoice

  Scenario: Monthly fee on account plan (with billable contracts)
    Given all the rolling updates features are off
    And I have billable_contracts feature enabled
    And the date is 1st January 2009
    And the buyer is signed up to account plan "Account Plan"
    And the buyer plan "Account Plan" contract is pending
    When time flies to 3rd March 2009
    Then the buyer should have 0 invoice

  Scenario: Monthly fee on service plan (with billable contracts)
    Given all the rolling updates features are off
    And I have billable_contracts feature enabled
    And the date is 1st January 2009
    And the buyer is signed up to service plan "Service Plan"
    And the buyer plan "Service Plan" contract is pending
    When time flies to 3rd March 2009
    Then the buyer should have 0 invoice

  Scenario: Monthly fee: contracts activated in middle of month. With billable contracts
    Given all the rolling updates features are off
    And I have billable_contracts feature enabled
    And the date is 1st January 2009
    And the buyer is signed up to service plan "Service Plan"
    And the buyer plan "Service Plan" contract is pending
    When time flies to 15th January 2009
    And the buyer plan "Service Plan" contract gets accepted
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
    And the buyer is signed up to service plan "Service Plan"
    And the buyer plan "Service Plan" contract is pending
    When time flies to 15th January 2009
    And the buyer plan "Service Plan" contract gets accepted
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
    And the buyer is signed up to service plan "Service Plan"
    And the buyer plan "Service Plan" contract is live
    When time flies to 3rd March 2009
    Then the buyer should have following line items for "January, 2009" invoice:
      | name                              | quantity |  cost    |
      | Fixed fee ('Service Plan')        |          | 17.00    |
      | Total cost                        |          | 17.00    |
    Then the buyer should have following line items for "February, 2009" invoice:
      | name                              | quantity |  cost    |
      | Fixed fee ('Service Plan')        |          | 31.00    |
      | Total cost                        |          | 31.00    |

