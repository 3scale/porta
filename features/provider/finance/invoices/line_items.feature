@javascript
Feature: Invoice line items

  As a provider I want to be able to add, edit and delete items from my customers' invoices

  Background:
    Given a provider is logged in on 1st February 2009
    And the provider is charging its buyers
    And a buyer "zoidberg"
    And the buyer has an invoice for February, 2009 with the following item:
      | Name    | Description     | Quantity | Cost |
      | Bananas | A bunch of them | 1        | 42   |
    And they go to the invoice admin portal page

  Scenario: Adding a new item
    Given the table should contain the following within the line items card:
      | Name    | Description     | Quantity | Price       | Charged |
      | Bananas | A bunch of them | 1        | EUR 42.0000 |         |
    And the total cost is "EUR 42.00"
    When they follow "Add" within the line items card
    And the modal is submitted with:
      | Name        | Refund           |
      | Quantity    | 1                |
      | Description | Very bad service |
      | Cost        | -200             |
    And wait a moment
    Then they should see the flash message "Line item added."
    And the table should contain the following within the line items card:
      | Name    | Description      | Quantity | Price         | Charged |
      | Bananas | A bunch of them  | 1        | EUR 42.0000   |         |
      | Refund  | Very bad service | 1        | EUR -200.0000 |         |
    And the total cost should be "EUR -158.00"

  Scenario: Deleting an item
    Given the table should contain the following within the line items card:
      | Name    | Description     | Quantity | Price       | Charged |
      | Bananas | A bunch of them | 1        | EUR 42.0000 |         |
    When they press "Delete"
    And wait a moment
    Then they should not see "Bananas"
    And the total cost should be "EUR 0.00"

  Scenario: Cost smaller than 0.01 is rounded up to 2 decimals
    Given the buyer has an invoice for January, 2009 with the following item:
      | Name        | Description      | Quantity | Cost   |
      | Apple       | Crunchy          | 1        | 1      |
      | Tiny grapes | They're so small | 95       | 0.0095 |
    When they go to the invoice admin portal page
    Then the total cost should be "EUR 1.01"

  Scenario: Cost smaller than 0.01 is rounded down to 2 decimals
    Given the buyer has an invoice for January, 2009 with the following item:
      | Name        | Description      | Quantity | Cost   |
      | Apple       | Crunchy          | 1        | 1      |
      | Tiny grapes | They're so small | 40       | 0.0040 |
    When they go to the invoice admin portal page
    Then the total cost should be "EUR 1.00"
