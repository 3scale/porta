@javascript
Feature: Audience > Billing > Earnings by month

  As a provider I want to see my earnings grouped by month.

  Background:
    Given a provider is logged in on 1st January 2025
    And a buyer "Bananas"
    And the provider is charging its buyers

  Scenario: Navigation
    Given the current page is the provider dashboard
    When they select "Audience" from the context selector
    And press "Billing" within the main menu
    And follow "Earnings by month" within the main menu
    Then they should be on the earnings by month page

  Scenario: Empty state
    When they go to the earnings by month page
    Then they should see an empty state

  Scenario: In process invoice
    Given the following invoices:
      | Buyer   | Month         | Friendly ID      | State  | Total cost |
      | Bananas | January, 2025 | 2025-01-00000001 | Unpaid | 42.00      |
      | Bananas | January, 2025 | 2025-01-00000002 | Unpaid | 48.00      |
    When they go to the earnings by month page
    Then the table should contain the following:
      | Month         | Total     | In process | Overdue   | Paid     |
      | January, 2025 | EUR 90.00 | EUR 0.00   | EUR 90.00 | EUR 0.00 |

  Scenario: Paid invoice
    Given the following invoices:
      | Buyer   | Month         | Friendly ID      | State | Total cost |
      | Bananas | January, 2025 | 2025-01-00000001 | Paid  | 42.00      |
    When they go to the earnings by month page
    Then the table should contain the following:
      | Month         | Total     | In process | Overdue  | Paid      |
      | January, 2025 | EUR 42.00 | EUR 0.00   | EUR 0.00 | EUR 42.00 |

  Scenario: Overdue invoice
    Given the following invoices:
      | Buyer   | Month         | Friendly ID      | State  | Total cost |
      | Bananas | January, 2025 | 2025-01-00000001 | Unpaid | 42 EUR     |
    And the buyer pays the invoice but failed
    When I go to the earnings by month page
    Then the table should contain the following:
      | Month         | Total     | In process | Overdue   | Paid     |
      | January, 2025 | EUR 42.00 | EUR 0.00   | EUR 42.00 | EUR 0.00 |

  Scenario: Filter invoices by year
    Given the following invoices:
      | Buyer   | Month          | Friendly ID      |
      | Bananas | January, 2025  | 2025-01-00000001 |
      | Bananas | February, 2024 | 2024-02-00000001 |
      | Bananas | March, 2023    | 2023-03-00000001 |
    And I go to the earnings by month page
    And the table should contain the following:
      | Month          | Total    | In process | Overdue  | Paid     |
      | January, 2025  | EUR 0.00 | EUR 0.00   | EUR 0.00 | EUR 0.00 |
      | February, 2024 | EUR 0.00 | EUR 0.00   | EUR 0.00 | EUR 0.00 |
      | March, 2023    | EUR 0.00 | EUR 0.00   | EUR 0.00 | EUR 0.00 |
    When the table is filtered with:
      | filter         | value |
      | Filter by year | 2024  |
    Then the table should contain the following:
      | Month          | Total    | In process | Overdue  | Paid     |
      | February, 2024 | EUR 0.00 | EUR 0.00   | EUR 0.00 | EUR 0.00 |
