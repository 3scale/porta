@ignore-backend @javascript
Feature: Audience > Billing > Invoices

  Background:
    Given a provider is logged in on 1st January 2011
    And the default product of the provider has name "My API"
    And the provider is charging its buyers in prepaid mode

  Rule: No invoices
    Background:
      Given buyers of the provider have no invoices

    Scenario: Empty state
      When they go to the admin portal invoices page
      Then should see "Nothing to see here"
      And should see "There are no invoices yet"

    @commit-transactions
    Scenario: Invoices are generated after some time
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

  Rule: Some invoices
    Background:
      Given a buyer "Zoidberg"
      And a buyer "Bender"
      And the following invoices:
        | Buyer    | Month          | Friendly ID      | State   |
        | Zoidberg | January, 2011  | 2011-01-00000001 | Open    |
        | Zoidberg | February, 2011 | 2011-02-00000001 | Pending |
        | Bender   | March, 2011    | 2011-03-00000001 | Open    |
        | Bender   | January, 2012  | 2012-01-00000001 | Open    |

    Scenario: Empty search state
      Given they go to the admin portal invoices page
      When the table is filtered with:
        | filter | value   |
        | Number | Bananas |
      Then they should see "No invoices found"
      When they follow "Clear all filters"
      Then they should see "January, 2011"

    Scenario: Display years of invoices when there are invoices
      Given an invoice of buyer "Zoidberg" for January, 2014 on 1st January 2014 (without scheduled jobs)
      When they go to the admin portal invoices page
      Then invoices can be filtered by the following years:
        | 2014 |
        | 2012 |
        | 2011 |
    @wip
    Scenario: Display only years belonging to the current provider
      Given a provider "bar.3scale.localhost"
      And provider "bar.3scale.localhost" is charging its buyers
      And a buyer "leela" signed up to provider "bar.3scale.localhost"
      And an invoice of buyer "leela" for January, 2011
      When provider "bar.3scale.localhost" logs in
      And they go to the admin portal invoices page
      Then invoices can be filtered by the following years:
        | 2011 |

    Scenario: Filter invoices by friendly id
      Given they go to the admin portal invoices page
      And the table should contain the following:
        | Number           | Account  | Month          | Cost     | State   |
        | 2011-01-00000001 | Zoidberg | January, 2011  | EUR 0.00 | Open    |
        | 2011-02-00000001 | Zoidberg | February, 2011 | 0.00     | Pending |
        | 2011-03-00000001 | Bender   | March, 2011    | EUR 0.00 | Open    |
        | 2012-01-00000001 | Bender   | January, 2012  | EUR 0.00 | Open    |
      When the table is filtered with:
        | filter | value  |
        | Number | 2012-* |
      Then the table should contain the following:
        | Number           | Account | Month         | Cost     | State |
        | 2012-01-00000001 | Bender  | January, 2012 | EUR 0.00 | Open  |

    @search
    Scenario: Filter invoices by buyer account
      Given they go to the admin portal invoices page
      And the table should contain the following:
        | Number           | Account  | Month          | Cost     | State   |
        | 2011-01-00000001 | Zoidberg | January, 2011  | EUR 0.00 | Open    |
        | 2011-02-00000001 | Zoidberg | February, 2011 | 0.00     | Pending |
        | 2011-03-00000001 | Bender   | March, 2011    | EUR 0.00 | Open    |
        | 2012-01-00000001 | Bender   | January, 2012  | EUR 0.00 | Open    |
      When the table is filtered with:
        | filter  | value  |
        | Account | Bender |
      Then the table should contain the following:
        | Number           | Account | Month         | Cost     | State |
        | 2011-03-00000001 | Bender  | March, 2011   | EUR 0.00 | Open  |
        | 2012-01-00000001 | Bender  | January, 2012 | EUR 0.00 | Open  |

    Scenario: Filter invoices by month
      Given they go to the admin portal invoices page
      And the table should contain the following:
        | Number           | Account  | Month          | Cost     | State   |
        | 2011-01-00000001 | Zoidberg | January, 2011  | EUR 0.00 | Open    |
        | 2011-02-00000001 | Zoidberg | February, 2011 | 0.00     | Pending |
        | 2011-03-00000001 | Bender   | March, 2011    | EUR 0.00 | Open    |
        | 2012-01-00000001 | Bender   | January, 2012  | EUR 0.00 | Open    |
      When the table is filtered with:
        | filter | value   |
        | Month  | January |
      Then the table should contain the following:
        | Number           | Account  | Month         | Cost     | State |
        | 2011-01-00000001 | Zoidberg | January, 2011 | EUR 0.00 | Open  |
        | 2012-01-00000001 | Bender   | January, 2012 | EUR 0.00 | Open  |

    Scenario: Filter invoices by year
      Given they go to the admin portal invoices page
      And the table should contain the following:
        | Number           | Account  | Month          | Cost     | State   |
        | 2011-01-00000001 | Zoidberg | January, 2011  | EUR 0.00 | Open    |
        | 2011-02-00000001 | Zoidberg | February, 2011 | 0.00     | Pending |
        | 2011-03-00000001 | Bender   | March, 2011    | EUR 0.00 | Open    |
        | 2012-01-00000001 | Bender   | January, 2012  | EUR 0.00 | Open    |
      When the table is filtered with:
        | filter | value |
        | Year   | 2012  |
      Then the table should contain the following:
        | Number           | Account | Month         | Cost     | State |
        | 2012-01-00000001 | Bender  | January, 2012 | EUR 0.00 | Open  |

    Scenario: Filter invoices by state
      Given they go to the admin portal invoices page
      And the table should contain the following:
        | Number           | Account  | Month          | Cost     | State   |
        | 2011-01-00000001 | Zoidberg | January, 2011  | EUR 0.00 | Open    |
        | 2011-02-00000001 | Zoidberg | February, 2011 | 0.00     | Pending |
        | 2011-03-00000001 | Bender   | March, 2011    | EUR 0.00 | Open    |
        | 2012-01-00000001 | Bender   | January, 2012  | EUR 0.00 | Open    |
      When the table is filtered with:
        | filter | value   |
        | State  | Pending |
      Then the table should contain the following:
        | Number           | Account  | Month          | Cost | State   |
        | 2011-02-00000001 | Zoidberg | February, 2011 | 0.00 | Pending |

    Scenario: Invoices from a deleted account
      Given account "Zoidberg" is deleted
      When they go to the admin portal invoices page
      Then the table should contain the following:
        | Number           | Account   | Month          | Cost     | State   |
        | 2011-01-00000001 | (deleted) | January, 2011  | EUR 0.00 | Open    |
        | 2011-02-00000001 | (deleted) | February, 2011 | 0.00     | Pending |
        | 2011-03-00000001 | Bender    | March, 2011    | EUR 0.00 | Open    |
        | 2012-01-00000001 | Bender    | January, 2012  | EUR 0.00 | Open    |
