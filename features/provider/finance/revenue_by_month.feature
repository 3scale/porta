@javascript
Feature: Group earnings by month
  In order to see me earnings
  As a provider
  I want to see the sumatory of paid invoices by month.

  Background:
    Given a provider is logged in
    And the provider is charging its buyers
    And a buyer "Bob Buyer"

  Scenario: In process invoice
    Given an invoice of the buyer with a total cost of 42.00 EUR
    And an invoice of the buyer with a total cost of 48.00 EUR
    When I go to the earnings by month page
    Then I should see in the invoice period for the column "in process" a cost of 90.00 EUR
    Then I should see in the invoice period for the column "overdue" a cost of 0.00 EUR
    Then I should see in the invoice period for the column "paid" a cost of 0.00 EUR
    Then I should see in the invoice period for the column "total" a cost of 90.00 EUR

  Scenario: Paid invoice
    Given an invoice of the buyer with a total cost of 42.00 EUR
    And the buyer pays the invoice
    When I go to the earnings by month page
    Then I should see in the invoice period for the column "in process" a cost of 0.00 EUR
    Then I should see in the invoice period for the column "overdue" a cost of 0.00 EUR
    And I should see in the invoice period for the column "paid" a cost of 42.00 EUR
    And I should see in the invoice period for the column "total" a cost of 42.00 EUR


  Scenario: Overdue invoice
    Given an invoice of the buyer with a total cost of 42.00 EUR
    And the buyer pays the invoice but failed
    When I go to the earnings by month page
    Then I should see in the invoice period for the column "in process" a cost of 0.00 EUR
    Then I should see in the invoice period for the column "overdue" a cost of 42.00 EUR
    Then I should see in the invoice period for the column "paid" a cost of 0.00 EUR
    Then I should see in the invoice period for the column "total" a cost of 42.00 EUR
