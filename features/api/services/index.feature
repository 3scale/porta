@javascript
Feature: Services index page
  As a provider
  I want to manage my Services

  Background:
    Given a provider is logged in

  @search
  Scenario: Sorting services
    When an admin is reviewing services index page
    Then they can filter the table by name
