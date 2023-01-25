Feature: ActiveDocs
  As a provider
  I want to manage my ActiveDocs

  Background:
    Given a provider is logged in

  Scenario: Index does show the API column
    Given a service with a Swagger 2 spec
    When an admin is reviewing the developer portal's active docs
    Then the table should contain a column for the service

  @javascript
  Scenario Outline: Create a spec for the first time
    Given an admin wants to add a spec to a new service "FooAPI"
    When they are reviewing the developer portal's active docs
    And follow "Create your first spec"
    And select "FooAPI" from "Service"
    And submit the ActiveDocs form with <swagger version>
    Then they should see the new spec

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |