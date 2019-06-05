@javascript
Feature: ActiveDocs pages
  As a provider
  I want to manage my ActiveDocs of a specific service

  Background:
    Given a provider is logged in
      And the provider has 1 active doc

  Scenario: Index does not show the API column
    When I go to the service active docs page
    Then the table should not contain the API

  Scenario: Update with failures and retry
    When I try to update the active docs of the service with invalid data
    Then I should see the active docs errors in the page
    When I select a service from the service selector
     And I try to update the active docs with valid data
    Then the api doc spec is saved with this service linked

  Scenario: Create with failures and retry
     And the service selector is not in the form
    When I try to create the active docs of the service with invalid data
    Then I should see the active docs errors in the page
     And the service selector is not in the form
