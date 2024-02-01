@javascript
Feature: Application API credentials

  Background:
    Given a provider
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the following application:
      | Buyer | Name   | Product |
      | Jane  | My App | My API  |
    And the provider logs in

  Rule: Backend v1
    Background:
      Given the product uses backend v1
      And the application user key is "key-123"
      And they go to the application's admin page

    Scenario: Set a custom user key
      Given they follow "Set a custom User Key" within the API Credentials card
      When the modal is submitted with:
        | User key | my-custom-key |
      Then they should see "User key has been updated."
      And the application user key should be "my-custom-key"

    Scenario: Field "User key" is required
      Given follow "Set a custom User Key" within the API Credentials card
      And there is a required field "User key"
      When the modal is submitted with:
        | User key |  |
      Then the application user key should still be "key-123"

    Scenario: Set an empty custom user key
      Given they follow "Set a custom User Key" within the API Credentials card
      When they fill in "User key" with "   "
      And press "Save"
      Then the application user key should still be "key-123"
      And should see "Key can't be blank."

    Scenario: Set custom user key fails
      Given they follow "Set a custom User Key" within the API Credentials card
      When the modal is submitted with:
        | User key | invalid-Ñ$% |
      Then the application user key should still be "key-123"
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
      And follow "Add Custom key" within the API Credentials card
      When the modal is submitted with:
        | Key | new-valid-key |
      Then should see "new-valid-key" within the API Credentials card

    Scenario: Adding a random key
      Given the application has no keys
      And they go to the application's admin page
      When follow "Add Random key" within the API Credentials card
      Then there is 1 key within the API Credentials card

    Scenario: Adding keys beyond the limit
      Given the application has 5 keys
      And they go to the application's admin page
      Then should see "Keys limit reached." within the API Credentials card

    Scenario: Field "Key" is required
      Given the application has 1 key
      And they go to the application's admin page
      When they follow "Add Custom key" within the API Credentials card
      And the modal is submitted with:
        | Key |  |
      Then there is a required field "Key"
      And there is 1 key

    Scenario: Keys are deleteable
      Given the application has the following keys:
        | key-1 |
        | key-2 |
      When they go to the application's admin page
      Then there should be a link to "Delete" that belongs to application key "key-1"
      And there should be a link to "Delete" that belongs to application key "key-2"

    Scenario: Deleting a key
      Given the application has the following keys:
        | key-1 |
        | key-2 |
      And the product has mandatory app key set to "false"
      And they go to the application's admin page
      When follow "Delete" that belongs to application key "key-1"
      And wait a moment
      Then there is 1 key

    Scenario: Deleting last key when not mandatory
      Given the application has 1 key
      And the product has mandatory app key set to "false"
      When they go to the application's admin page
      And follow "Delete" within the API Credentials card
      And wait a moment
      Then there are 0 keys

    Scenario: Trying to delete last key but it's mandatory
      Given the application has the following key:
        | the-only-key |
      And the product has mandatory app key set to "true"
      When they go to the application's admin page
      Then there shouldn't be a link to "Delete" that belongs to application key "the-only-key"
