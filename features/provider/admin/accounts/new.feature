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
    Then "Username" shows error "is too short (minimum is 3 characters)"
    And "Email" shows error "should look like an email address"
    And "Organization/Group Name" shows error "can't be blank"
    But "Password" doesn't show any error

  Scenario: Create a provider account with invalid data
    Given they go to the new provider account page
    When the form is submitted with:
      | Email    | a@a.e  |
      | Password | 123456 |
    Then "Email" shows error "is too short (minimum is 6 characters)"
    And "Password confirmation" shows error "doesn't match Password"
