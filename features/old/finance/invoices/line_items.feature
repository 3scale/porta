@javascript
Feature: Provider manages line items
  In order to have full control over amounts billed
  As a provider
  I want to add/delete/edit line items on my customer's invoices

# TODO: create the invoice artificially and not by billing mechanism
Background:
  Given a provider "foo.example.com" with billing enabled
    Given provider "foo.example.com" has "finance" switch allowed
    And an application plan "Fixed" of provider "foo.example.com" for 200 monthly
    And a buyer "zoidberg" signed up to application plan "Fixed"
    And an invoice of buyer "zoidberg" for February, 2009 with items
      | name | cost |
      | Old  |   42 |

    And current domain is the admin domain of provider "foo.example.com"
   When I log in as provider "foo.example.com"

    And I navigate to my earnings
    And I follow "February, 2009"
    And I follow "Show"

Scenario: Create line item
  When I follow "Add"
    And I fill in the following:
      | Name        |           Refund |
      | Quantity    |                1 |
      | Description | Very bad service |
      | Cost        |             -200 |
    And I press "Create Line Item"

   Then I should see line items
      | name       | cost |
      | Old        |   42 |
      | Refund     | -200 |
      | Total cost | -158 |

Scenario: Delete line item
   When I press "Delete"
   Then I should see line items
      | name       | cost |
      | Total cost |    0 |

Scenario: Rounding to 2 decimals renders 0 for sub 2dec amounts
  When I follow "Add"
    And I fill in the following:
    | Name        |  tiny1 |
    | Quantity    |     1 |
    | Description |  desc |
    | Cost        | 0.001 |
    And I press "Create Line Item"
   Then I should see line items
      | name | cost |
      | Old  |   42 |
      | tiny1 | 0.00 |
      | Total cost | 42 |

Scenario: Rounding to 2 decimals rounds to 0.01
  When I follow "Add"
    And I fill in the following:
    | Name        | tiny1 |
    | Quantity    |     1 |
    | Description |  desc |
    | Cost        | 0.004 |
    And I press "Create Line Item"
  When I follow "Add"
    And I fill in the following:
    | Name        | tiny2 |
    | Quantity    |     1 |
    | Description |  desc |
    | Cost        | 0.004 |
    And I press "Create Line Item"
  When I follow "Add"
    And I fill in the following:
    | Name        | tiny3 |
    | Quantity    |     1 |
    | Description |  desc |
    | Cost        | 0.004 |
    And I press "Create Line Item"
   Then I should see line items
      | name       |  cost |
      | Old        |    42 |
      | tiny1       | 0.004 |
      | tiny2       | 0.004 |
      | tiny3       | 0.004 |
      | Total cost | 42.01 |

Scenario: Rounding to 2 decimals
  When I follow "Add"
    And I fill in the following:
    | Name        | tiny |
    | Quantity    |    1 |
    | Description | desc |
    | Cost        | 0.01 |

    And I press "Create Line Item"
   Then I should see line items
      | name       |  cost |
      | Old        |    42 |
      | tiny       |  0.01 |
      | Total cost | 42.01 |
