@javascript
Feature: Backend APIs index page
  As a provider
  I want to manage my Backends

  Background:
    Given a provider is logged in

  @search
  Scenario: Sorting services
    When an admin is reviewing backend apis index page
    Then they can filter the table by name
