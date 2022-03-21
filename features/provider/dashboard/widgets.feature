@javascript
Feature: Dashboard Widgets
  In order to navigate easily to products and backends

  Background:
    Given a provider is logged in

  Scenario: Find products and backends quickly
    Given 10 products and 10 backend apis
    When an admin is at the dashboard
    Then the most recently updated products and backends can be found in the dashboard

  Scenario: Add new products and backends quickly
    When an admin is at the dashboard
    Then products can be created from the dashboard
    And backends can be created from the dashboard
