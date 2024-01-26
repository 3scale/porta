@javascript
Feature: Application API credentials

  Background:
    Given a provider
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the buyer has an application "My App" for the product
    And the provider logs in

  Rule: Backend v1
    Background:
      Given the product uses backend v1
      And they go to the application's admin page

    Scenario: Set a custom user key
      When follow "Set a custom User Key" within the API Credentials card
      And fill in "User key" with "my-custom-key"
      And press "Save"
      Then should see "my-custom-key" within the API Credentials card
      And should see "User key has been updated."

    Scenario: Field "User key" is required
      When follow "Set a custom User Key" within the API Credentials card
      And fill in "User key" with ""
      And press "Save"
      Then there is a required field "User key"
      And the application's user key has not changed

    Scenario: Set an empty custom user key
      When follow "Set a custom User Key" within the API Credentials card
      And fill in "User key" with "   "
      And press "Save"
      Then the application's user key has not changed
      And should see "Key can't be blank."

    Scenario: Set custom user key fails
      When follow "Set a custom User Key" within the API Credentials card
      And fill in "User key" with "invalid-Ñ$%"
      And press "Save"
      Then the application's user key has not changed
      And should see "invalid"

  Rule: Backend v2
    Background:
      Given the product uses backend v2
      And they go to the application's admin page

    Scenario: Application keys
      Given the application has the following keys:
        | key2345 |
        | key2346 |
      When they go to the application's admin page
      Then they should see "key2345" within the API Credentials card
      And should see "key2346" within the API Credentials card

    Scenario: Adding a custom key
      Given they go to the application's admin page
      When follow "Add Custom key" within the API Credentials card
      And fill in "Key" with "new-valid-key"
      And press "Save"
      Then should see "new-valid-key" within the API Credentials card

    Scenario: Adding a random key
      Given the application has 0 keys
      And they go to the application's admin page
      When follow "Add Random key" within the API Credentials card
      Then there is 1 key
      And there is 1 key within the API Credentials card

    Scenario: Adding keys beyond the limit
      Given the application has 5 keys
      And they go to the application's admin page
      Then should see "Keys limit reached." within the API Credentials card

    Scenario: Field "Key" is required
      Given the application has 1 key
      And they go to the application's admin page
      When follow "Add Custom key" within the API Credentials card
      And fill in "Key" with ""
      And press "Save"
      Then there is a required field "Key"
      And there is 1 key

    Scenario: Keys are deleteable
      Given the application has 2 keys
      When they go to the application's admin page
      Then any of the application keys can be deleted

    Scenario: Deleting a key
      Given the application has 2 keys
      And they go to the application's admin page
      When follow "Delete" within the API Credentials card
      Then there is 1 key

    Scenario: Deleting last key when not mandatory
      Given the application has 1 key
      And the product don't have mandatory app key
      When they go to the application's admin page
      And follow "Delete" within the API Credentials card
      Then there is 0 keys

    Scenario: Trying to delete last key but it's mandatory
      Given the application has 1 key
      And the product has mandatory app key
      When they go to the application's admin page
      Then the application keys cannot be deleted
