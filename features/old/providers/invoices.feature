@javascript
Feature: Provider invoices for 3scale
  In order to pay to 3scale
  As a provider
  I want to see and admin my invoices

  Background:
    Given the time is 1st May 2009
    And master provider was created on May 01, 2009
    And provider "master" is charging its buyers
    And the default product of provider "master" has name "Master API"
    And the following application plans:
      | Product    | Name | Cost per month |
      | Master API | Base | 0              |
      | Master API | Mega | 31             |
      | Master API | Pro  | 3100           |

  Scenario: List my invoices - full for Mega
    And a provider "foo.3scale.localhost" signed up to plan "Mega"
    And 1 day passes
    When I am logged in as provider "foo.3scale.localhost" on its admin domain
    And I go to my invoices from 3scale page
    Then I should see 1 invoices
    When time flies to 1st June 2009
    And I go to my invoices from 3scale page
    Then I should see 2 invoices

  Scenario: List my invoices - empty for Base
    Given a provider "foo.3scale.localhost" signed up to plan "Base"
    And I am logged in as provider "foo.3scale.localhost" on its admin domain
    And I go to my invoices from 3scale page
    Then I should see "You have no invoices"

  @stats
  Scenario: Invoice price is ok when starting from power
    Given the time is 5th May 2009
    And a provider "foo.3scale.localhost" signed up to plan "Mega"
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And time flies to 25th May 2009
    And the provider changes to application plan "Pro"
    And time flies to 1st June 2009
    And I navigate to invoice issued for me in "May, 2009"
    Then I should see line items
      | name               | quantity | cost   |
      | Fixed fee ('Mega') |          | 27.00  |
      | Refund ('Mega')    |          | -7.00  |
      | Fixed fee ('Pro')  |          | 700.00 |
      | Total cost         |          | 720.00 |

  @stats
  Scenario: Invoice price is ok when starting from base
    Given the time is 1st May 2009
    And a provider "foo.3scale.localhost" signed up to plan "Base"
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    Given the time is 5th May 2009
    And I log in as provider "foo.3scale.localhost"
    And the provider changes to application plan "Mega"
    And time flies to 25th May 2009
    And the provider changes to application plan "Pro"
    And time flies to 1st June 2009
    And I navigate to invoice issued for me in "May, 2009"
    Then I should see line items
      | name               | quantity | cost   |
      | Fixed fee ('Mega') |          | 27.00  |
      | Refund ('Mega')    |          | -7.00  |
      | Fixed fee ('Pro')  |          | 700.00 |
      | Total cost         |          | 720.00 |
