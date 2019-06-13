Feature: ActiveDocs pages
  As a provider
  I want to manage my ActiveDocs

  Background:
    Given a provider is logged in
      And the provider has 1 active doc

  Scenario: Index shows the API column
    When I go to the provider active docs page
    Then the table should contain the API

  Scenario: Update with failures and retry
    When I try to update the active docs with invalid data
    Then I should see the active docs errors in the page
    When I select a service from the service selector
     And I try to update the active docs with valid data
    Then the api doc spec is saved with this service linked

  Scenario: Create with failures and retry
    When I try to create the active docs with invalid data
    Then I should see the active docs errors in the page
    When I select a service from the service selector
     And I try to create the active docs with valid data
    Then the api doc spec is saved with this service linked
