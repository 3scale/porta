@javascript
Feature: Dashboard Widgets
  In order to navigate easily to products and backends

  Background:
    Given a provider is logged in

  Scenario: Products and Backends widget
    When an admin that wants to find products and backends quickly
    Then the most recently updated products and backends can be found in the Dashboard
