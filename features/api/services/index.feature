@javascript
Feature: Services index page
  As a provider
  I want to manage my Services

  Background:
    Given a provider is logged in

  @search
  Scenario: Sorting services
    Given a service "First"
    And a service "Last"
    When an admin is reviewing services index page
    Then they can filter the table by "Name"
