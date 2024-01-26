Feature: Developer portal application referrer filters

  Background:
    Given a provider
    And a product "My API"
    And the product does require referrer filters
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the buyer has an application "My App" for the product
    And the buyer logs in

  Rule: Referrer filters not required
    Background:
      Given the product does not require referrer filters

    Scenario: Referrer filters not visible
      Given the product does not require referrer filters
      And they go to the application's dev portal page
      Then they should not see "Referrer Filters"

  Rule: Referrer filters required
    Background:
      Given the product does require referrer filters

    Scenario: List of referrer filters
      Given the application has the following referrer filters:
        | foo.example.org |
        | bar.example.org |
      When they go to the application's dev portal page
      Then they should see "foo.example.org" within the referrer filters
      And they should see "bar.example.org" within the referrer filters

    Scenario: Creating a referrer filter
      Given they go to the application's dev portal page
      And fill in "referrer_filter" with "foo.example.org" within the referrer filters
      And press "Add" within the referrer filters
      And wait a moment
      Then they should see "foo.example.org" within the referrer filters

    Scenario: Creating an invalid referrer filter
      Given they go to the application's dev portal page
      And fill in "referrer_filter" with "" within the referrer filters
      And press "Add" within the referrer filters
      And wait a moment
      Then they should see the flash message "referrer filter can't be blank"

    Scenario: Can't create new referrer filters once the limit is reached
      Given the application can't have more referrer filters
      And they go to the application's dev portal page
      When fill in "referrer_filter" with "foo.example.org" within the referrer filters
      And press "Add" within the referrer filters
      And wait a moment
      Then they should see the flash message "Limit reached"
      And they should not see "foo.example.org" within the referrer filters

    Scenario: Deleting a referrer filter
      Given the application has the following referrer filters:
        | foo.example.org |
      And they go to the application's dev portal page
      And they delete the referrer filter "foo.example.org"
      Then they should not see "foo.example.org" within the referrer filters
