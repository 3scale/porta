@javascript
Feature: Provider accounts management

  Background:
    Given a master admin with extra fields is logged in

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
      | Password                | 123456               |
      | Password confirmation   | 123456               |
      | Organization/Group Name | The Provider         |
    Then they should see the flash message "Tenant account was successfully created."
    And the current page is the overview page of account "The Provider"

  Scenario: Validate missing fields
    Given they go to the new provider account page
    When the form is submitted with:
      | Username                |  |
      | Email                   |  |
      | Password                |  |
      | Password confirmation   |  |
      | Organization/Group Name |  |
    Then field "Username" has inline error "is too short (minimum is 3 characters)"
    And field "Email" has inline error "should look like an email address"
    And field "Organization/Group Name" has inline error "can't be blank"
    But field "Password" has no inline error

  Scenario: Create a provider account with invalid data
    Given they go to the new provider account page
    When the form is submitted with:
      | Email    | a@a.e  |
      | Password | 123456 |
    Then field "Email" has inline error "is too short (minimum is 6 characters)"
    And field "Password confirmation" has inline error "doesn't match Password"
