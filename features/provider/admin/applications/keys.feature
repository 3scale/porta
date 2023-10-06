@javascript @ignore-backend
Feature: Applications details
  In order to manage application keys
  As a provider
  I want to be able to add and remove keys

  Background:
    Given a provider is logged in
    And the provider has a buyer with an application

  Rule: Backend v1
    Background:
      Given the provider uses backend v1 in his default service
      And they are reviewing the buyer's application details

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
      Then fields should be required:
        | required |
        | User key |
      Then the application's user key has not changed

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
      Given the provider uses backend v2 in his default service
      And they are reviewing the buyer's application details

    Scenario: Adding a custom key
      Given they are reviewing the buyer's application details
      When follow "Add Custom key" within the API Credentials card
      And fill in "Key" with "new-valid-key"
      And press "Save"
      Then should see "new-valid-key" within the API Credentials card

    Scenario: Adding a random key
      Given the application has no keys
      And they are reviewing the buyer's application details
      When follow "Add Random key" within the API Credentials card
      And the application shows 1 key

    Scenario: Adding keys beyond the limit
      Given the key limit for the application is reached
      And they are reviewing the buyer's application details
      Then no more keys can be added

    Scenario: Field "Key" is required
      Given the application has 1 key
      And they are reviewing the buyer's application details
      When follow "Add Custom key" within the API Credentials card
      And fill in "Key" with ""
      And press "Save"
      Then fields should be required:
        | required |
        | Key      |
      And the application shows 1 key

    Scenario: Keys are deleteable
      Given the application has 2 keys
      When they are reviewing the buyer's application details
      Then any of the application keys can be deleted

    Scenario: Deleting a key
      Given the application has 2 keys
      And they are reviewing the buyer's application details
      When follow "Delete" within the API Credentials card
      Then the application shows 1 key

    Scenario: Deleting last key when not mandatory
      Given the application has 1 key
      And the application's product don't have mandatory app key
      When they are reviewing the buyer's application details
      When follow "Delete" within the API Credentials card
      Then the application shows 0 keys

    Scenario: Trying to delete last key but it's mandatory
      Given the application has 1 key
      And the application's product has mandatory app key
      When they are reviewing the buyer's application details
      Then the application keys cannot be deleted
