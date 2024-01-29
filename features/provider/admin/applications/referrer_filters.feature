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
      Then they don't see the referrer filters

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
      And fill in "referrer_filter" with "foo.example.org" within the referrer filters
      And press "Add" within the referrer filters
      And wait a moment
      Then they should see "foo.example.org" within the referrer filters

    Scenario: Delete a referrer filter
      Given the application has the following referrer filters:
        | foo.example.org |
      And they go to the application's admin page
      And they should see "foo.example.org" within the referrer filters
      When they delete the referrer filter "foo.example.org"
      Then they should not see "foo.example.org" within the referrer filters
