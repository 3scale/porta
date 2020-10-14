Feature: Dashboard search bar
  In order to navigate easily to products and backends
  As a provider
  I want to be able to filter them by name

  Background:
    Given a provider is logged in
    And a service "My Fancy Product"
    And a service "My Regular Product"
    And a backend api "My Fancy Backend API"
    And a backend api "My Regular Backend API"
    And I go to the provider dashboard

  @javascript
  Scenario: Products widget
    Given I should see "My Fancy Product" in the apis dashboard products widget
    And I should see "My Regular Product" in the apis dashboard products widget

  @javascript
  Scenario: Backends widget
    Given I should see "My Fancy Backend API" in the apis dashboard backends widget
    And I should see "My Regular Backend API" in the apis dashboard backends widget
