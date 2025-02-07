@javascript
Feature: Invoice generation

  Invoices should be generated monthly

  Background:
    Given a provider is logged in on 1st January 2011
    And the default product of the provider has name "My API"
    And the provider is charging its buyers in prepaid mode

  @commit-transactions @ignore-backend
  Scenario: Multiple buyers subscribed to a paid plan
    Given the following application plans:
      | Product | Name    | Cost per month |
      | My API  | Premium | 200            |
    And a buyer "Jane" signed up to application plan "Premium"
    And time flies to 10th February 2011
    And a buyer "Bob" signed up to application plan "Premium"
    And time flies to 20th April 2011
    When they go to the admin portal invoices page
    Then the table should contain the following:
      | Number           | Account | Month          | Cost       | State  |
      | 2011-04-00000001 | Jane    | April, 2011    | EUR 200.00 | Failed |
      | 2011-04-00000002 | Bob     | April, 2011    | EUR 200.00 | Failed |
      | 2011-03-00000001 | Jane    | March, 2011    | EUR 200.00 | Failed |
      | 2011-03-00000002 | Bob     | March, 2011    | EUR 200.00 | Failed |
      | 2011-02-00000002 | Bob     | February, 2011 | EUR 135.71 | Failed |
      | 2011-02-00000001 | Jane    | February, 2011 | EUR 200.00 | Failed |
      | 2011-01-00000001 | Jane    | January, 2011  | EUR 200.00 | Failed |
