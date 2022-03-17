@javascript
Feature: Dashboard Widgets
  In order to navigate easily to products and backends

  Background:
    Given a provider is logged in

  Scenario: Find products and backends quickly
    When an admin needs to find a product or backend quickly
    Then the most recently updated products and backends can be found in the dashboard

  Scenario: Add new products and backends quickly
    When an admin needs a new product or backend quickly
    Then products and backends can be created from the dashboard
