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
      Then the application now has user key "my-custom-key"

    Scenario: Set an empty custom user key
      When follow "Set a custom User Key" within the API Credentials card
      And fill in "User key" with ""
      And press "Save"
      Then the application's user key has not changed
      And I should see "Key can't be blank"

    Scenario: Set custom user key fails
      When follow "Set a custom User Key" within the API Credentials card
      And fill in "User key" with "invalid-Ñ$%"
      And press "Save"
      Then the application's user key has not changed
      And I should see "Enter a valid key"

  Rule: Backend v2
    Background:
      Given the provider uses backend v2 in his default service
      And they are reviewing the buyer's application details

    Scenario: Remove and add keys
      Given the key limit for the application is reached
      Then I should see application keys limit reached error
      # When I follow "Delete" for first application key
      # Then I should not see application keys limit reached error
      # And I should see "Add Random key"
      # And I should see "Add Custom key"
      # When I follow "Add Random key"
      # Then I should see application keys limit reached error
