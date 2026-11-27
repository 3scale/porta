@javascript
Feature: Provider's application referrer filters

  Background:
    Given a provider
    And a product "My API"
    And the product uses backend v2
    And the product does require referrer filters
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the following application:
      | Buyer | Name   | Product |
      | Jane  | My App | My API  |
    And the provider logs in

    Scenario: Referrer filters card visibility
      Given they go to the application's admin page
      Then they should see "Referrer filters"
      When the product does not require referrer filters
      And they go to the application's admin page
      Then they should not see "Referrer filters"

    Scenario: List referrer filters
      Given the application has the following referrer filters:
        | foo.example.org |
        | bar.example.org |
      When they go to the application's admin page
      Then they should see "foo.example.org" within the Referrer filters card
      And they should see "bar.example.org" within the Referrer filters card

    Scenario: Creating a referrer filter
      Given they go to the application's admin page
      When they fill in "referrer_filter" with "foo.example.org" within the Referrer filters card
      And press "Add filter" within the Referrer filters card
      And wait a moment
      Then they should see "foo.example.org" within the Referrer filters card

    Scenario: Delete a referrer filter
      Given the application has the following referrer filters:
        | foo.example.org |
      And they go to the application's admin page
      When they should see "foo.example.org" within the Referrer filters card
      And they press "Delete" that belongs to the referrer filter "foo.example.org"
      And confirm the dialog
      Then they should not see "foo.example.org" within the Referrer filters card

    Scenario: Can't create more than 5 referrer filters
      Given the application has the following referrer filters:
        | foo1.example.org |
        | foo2.example.org |
        | foo3.example.org |
        | foo4.example.org |
      And they go to the application's admin page
      And there should be a button to "Add filter" within the Referrer filters card
      When they fill in "referrer_filter" with "foo5.example.org" within the Referrer filters card
      And press "Add filter" within the Referrer filters card
      Then there should not be a button to "Add filter" within the Referrer filters card
      And they should see "5 of 5" within the Referrer filters card

    Scenario: Remove filter after reaching the limit
      Given the application has the following referrer filters:
        | foo1.example.org |
        | foo2.example.org |
        | foo3.example.org |
        | foo4.example.org |
        | foo5.example.org |
      And they go to the application's admin page
      And there should not be a button to "Add filter" within the Referrer filters card
      And they should see "5 of 5" within the Referrer filters card
      When they press "Delete" that belongs to the referrer filter "foo1.example.org"
      And confirm the dialog
      Then there should be a button to "Add filter" within the Referrer filters card
      And they should see "4 of 5" within the Referrer filters card

    Scenario: Submitting an empty referrer filter shows an inline error
      Given they go to the application's admin page
      When press "Add filter" within the Referrer filters card
      And wait a moment
      Then they should see "referrer filter can't be blank and referrer filter invalid" within the Referrer filters card

    Scenario: Submitting an invalid referrer filter shows an inline error
      Given they go to the application's admin page
      When they fill in "referrer_filter" with "not valid!" within the Referrer filters card
      And press "Add filter" within the Referrer filters card
      And wait a moment
      Then they should see "referrer filter invalid" within the Referrer filters card

    Scenario: Error clears after a successful submission
      Given they go to the application's admin page
      When they fill in "referrer_filter" with "not valid!" within the Referrer filters card
      And press "Add filter" within the Referrer filters card
      And wait a moment
      And they fill in "referrer_filter" with "foo.example.org" within the Referrer filters card
      And press "Add filter" within the Referrer filters card
      And wait a moment
      Then they should see "foo.example.org" within the Referrer filters card
      And they should not see "referrer filter invalid" within the Referrer filters card
