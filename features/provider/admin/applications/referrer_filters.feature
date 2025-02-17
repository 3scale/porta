@javascript
Feature: Providers's application referrer filters

  Background:
    Given a provider
    And a product "My API"
    And the product uses backend v2
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the following application:
      | Buyer | Name   | Product |
      | Jane  | My App | My API  |
    And the provider logs in

  Rule: Referrer filters not required
    Background:
      Given the product does not require referrer filters

    Scenario: Referrer filters not visible
      When they go to the application's admin page
      Then they shouldn't be able to see the referrer filters

  Rule: Referrer filters required
    Background:
      Given the product does require referrer filters

    Scenario: List referrer filters
      Given the application has the following referrer filters:
        | foo.example.org |
        | bar.example.org |
      When they go to the application's admin page
      Then they should see "foo.example.org" within the referrer filters
      And they should see "bar.example.org" within the referrer filters

    Scenario: Creating a referrer filter
      Given they go to the application's admin page
      When they fill in "referrer_filter" with "foo.example.org" within the referrer filters
      And press "Add Filter" within the referrer filters
      And wait a moment
      Then they should see "foo.example.org" within the referrer filters

    Scenario: Delete a referrer filter
      Given the application has the following referrer filters:
        | foo.example.org |
      And they go to the application's admin page
      When they should see "foo.example.org" within the referrer filters
      And they press "Delete" that belongs to the referrer filter "foo.example.org"
      Then they should not see "foo.example.org" within the referrer filters

    Scenario: Can't create more than 5 referrer filters
      Given the application has the following referrer filters:
        | foo1.example.org |
        | foo2.example.org |
        | foo3.example.org |
        | foo4.example.org |
      And they go to the application's admin page
      And there should be a button to "Add Filter" within the referrer filters
      When they fill in "referrer_filter" with "foo5.example.org" within the referrer filters
      And press "Add Filter" within the referrer filters
      Then there should not be a button to "Add Filter" within the referrer filters
      And they should see "At most 5 referrer filters are allowed." within the referrer filters

    Scenario: Remove filter after reaching the limit
      Given the application has the following referrer filters:
        | foo1.example.org |
        | foo2.example.org |
        | foo3.example.org |
        | foo4.example.org |
        | foo5.example.org |
      And they go to the application's admin page
      And there should not be a button to "Add Filter" within the referrer filters
      And they should see "At most 5 referrer filters are allowed." within the referrer filters
      When they press "Delete" that belongs to the referrer filter "foo1.example.org"
      Then there should be a button to "Add Filter" within the referrer filters
      And they should not see "At most 5 referrer filters are allowed." within the referrer filters
