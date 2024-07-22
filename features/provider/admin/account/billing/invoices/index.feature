@javascript
Feature: Account Settings > Billing > 3scale Invoices

  As a provider, I want to see and admin my invoices of payments to 3scale

  Background:
    Given the time is 1st May 2009
    And master provider was created on May 01, 2009
    And provider "master" is charging its buyers
    And the default product of provider "master" has name "Master API"
    And the following application plans:
      | Product    | Name    | Cost per month |
      | Master API | Free    | 0              |
      | Master API | Basic   | 31             |
      | Master API | Premium | 3100           |

  Scenario: Empty view
    Given a provider signed up to plan "Premium"
    And the provider has no invoices
    When the provider logs in
    And they go to the 3scale invoices page
    Then they should see "You have no invoices"

  Scenario: First invoice is generated after 1 day
    Given a provider signed up to plan "Premium"
    And the provider logs in
    When 1 day passes
    And they go to the 3scale invoices page
    Then the table should contain the following:
      | ID               | Month               | State | Amount       |
      | 2009-05-00000001 | May, 2009 (current) | open  | EUR 3,100.00 |

  Scenario: Invoices are generated and finalized month by month
    Given a provider signed up to plan "Premium"
    And the provider logs in
    When time flies to 1st June 2009
    And they go to the 3scale invoices page
    Then the table should contain the following:
      | ID               | Month                | State     | Amount       |
      | 2009-06-00000001 | June, 2009 (current) | open      | EUR 3,100.00 |
      | 2009-05-00000001 | May, 2009            | finalized | EUR 3,100.00 |

  Scenario: No invoices are generated for a free plan
    Given a provider signed up to plan "Free"
    And the provider logs in
    When time flies to 1st June 2009
    And they go to the 3scale invoices page
    Then they should see "you have no invoices"

  Scenario: Invoices are correct when provider changes from Basic to Premium
    Given the time is 5th May 2009
    And a provider signed up to plan "Basic"
    And time flies to 25th May 2009
    And the provider changes to application plan "Premium"
    And time flies to 1st June 2009
    When the provider logs in
    And they go to the 3scale invoice for "May, 2009"
    Then I should see line items
      | name                  | quantity | cost   |
      | Fixed fee ('Basic')   |          | 27.00  |
      | Refund ('Basic')      |          | -7.00  |
      | Fixed fee ('Premium') |          | 700.00 |
      | Total cost            |          | 720.00 |

  Scenario: Invoices are correct when provider changes from Free to Basic
    Given the time is 1st May 2009
    And a provider signed up to plan "Free"
    And time flies to 5th May 2009
    And the provider changes to application plan "Basic"
    And time flies to 25th May 2009
    And the provider changes to application plan "Premium"
    And time flies to 1st June 2009
    When the provider logs in
    And they go to the 3scale invoice for "May, 2009"
    Then I should see line items
      | name                  | quantity | cost   |
      | Fixed fee ('Basic')   |          | 27.00  |
      | Refund ('Basic')      |          | -7.00  |
      | Fixed fee ('Premium') |          | 700.00 |
      | Total cost            |          | 720.00 |
