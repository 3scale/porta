@javascript
Feature: Dashboard Widgets
  In order to navigate easily to products and backends

  Background:
    Given a provider is logged in

  Scenario: Find products and backends quickly
    Given 10 products and 10 backend apis
    When they go to the provider dashboard
    Then the most recently updated products and backends can be found in the dashboard

  Scenario: Provider can't create new products, only backends
    Given the provider has "can create service" set to "false"
    And the provider has "multiple_services" switch denied
    When they go to the provider dashboard
    Then there should not be a link to "Create Product" within the products widget
    And there should be a link to "Create Backend" within the backends widget

  Scenario: Add new products and backends quickly
    Given the provider has "can create service" set to "true"
    And the provider has "multiple_services" switch allowed
    When they go to the provider dashboard
    Then there should be a link to "Create Product" within the products widget
    And there should be a link to "Create Backend" within the backends widget
