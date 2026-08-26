@javascript
Feature: Provider accounts management

  Background:
    Given master admin is logged in

  Scenario: Navigation via empty state action
    Given the current page is the provider dashboard
    When they follow "0 Accounts"
    And follow "Add your first account"
    Then the current page is the new provider account page

  Scenario: Navigation via toolbar
    Given a provider exists
    And they go to the provider dashboard
    When they follow "1 Account"
    And select toolbar action "Add an account"
    Then the current page is the new provider account page

  Scenario: Create a provider account
    Given they go to the new provider account page
    When the form is submitted with:
      | Username                | usernamepro          |
      | Email                   | provider@example.com |
      | Password                | superSecret1234#               |
      | Password confirmation   | superSecret1234#               |
      | Organization/Group Name | The Provider         |
    Then they should see a toast alert with text "Tenant account was successfully created"
    And the current page is the overview page of account "The Provider"

  Scenario: Create a provider account with invalid data
    Given they go to the new provider account page
    When the form is submitted with:
      | Username | u |
      | Email    | invalid |
      | Password | superSecret1234# |
      | Password confirmation | 1234superSecret# |
      | Organization/Group Name | Some Provider |
    Then field "Username" has inline error "is too short (minimum is 3 characters)"
    And field "Email" has inline error "should look like an email address"
    And field "Password confirmation" has inline error "doesn't match Password"
