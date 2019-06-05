@javascript
Feature: Provider invoices for 3scale
  In order to pay to 3scale
  As a provider
  I want to see and admin my invoices

  Background:
    Given the time is 1st May 2009
      And provider "master" is charging
    Given an application plan "Base" of provider "master" for 0 monthly
      And an application plan "Mega" of provider "master" for 31 monthly
      And an application plan "Pro" of provider "master" for 3100 monthly

  Scenario: List my invoices - full for Mega
    And a provider "foo.example.com" signed up to plan "Mega"
      And 1 day passes

     When I am logged in as provider "foo.example.com" on its admin domain
      And I go to my invoices from 3scale page
     Then I should see 1 invoices

     When time flies to 1st June 2009
      And I go to my invoices from 3scale page
     Then I should see 2 invoices


  Scenario: List my invoices - empty for Base
    Given a provider "foo.example.com" signed up to plan "Base"
      And I am logged in as provider "foo.example.com" on its admin domain
      And I go to my invoices from 3scale page
     Then I should see "You have no invoices"


  @stats
  Scenario: Invoice price is ok when starting from power
    Given the time is 5th May 2009
      And a provider "foo.example.com" signed up to plan "Mega"
    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

      And time flies to 25th May 2009
      And I change application plan to "Pro"
      And time flies to 1st June 2009

      And I navigate to invoice issued for me in "May, 2009"
    Then I should see line items
        | name                | quantity |   cost |
        | Fixed fee ('Mega') |          |  27.00 |
        | Refund ('Mega')    |          |  -7.00 |
        | Fixed fee ('Pro')   |          | 700.00 |
        | Total cost          |          | 720.00 |

  @stats
  Scenario: Invoice price is ok when starting from base
    Given the time is 1st May 2009
      And a provider "foo.example.com" signed up to plan "Base"
    Given current domain is the admin domain of provider "foo.example.com"
    Given the time is 5th May 2009
      And I log in as provider "foo.example.com"
      And I change application plan to "Mega"

      And time flies to 25th May 2009
      And I change application plan to "Pro"
      And time flies to 1st June 2009
      And I navigate to invoice issued for me in "May, 2009"
      Then I should see line items
        | name                | quantity |   cost |
        | Fixed fee ('Mega') |          |  27.00 |
        | Refund ('Mega')    |          |  -7.00 |
        | Fixed fee ('Pro')   |          | 700.00 |
        | Total cost          |          | 720.00 |
