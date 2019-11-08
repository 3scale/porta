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
  Scenario: Filtering products
    When I select the products tab
    And I should see "My Fancy Product" in the apis dashboard products tabs section
    And I should see "My Regular Product" in the apis dashboard products tabs section
    Then I search for "My Fan" using the products search bar
    And I should see "My Fancy Product" in the apis dashboard products tabs section
    And I should not see "My Regular Product" in the apis dashboard products tabs section
    Then I search for "My Foo Foo" using the products search bar
    And I should not see "My Fancy Product" in the apis dashboard products tabs section
    And I should not see "My Regular Product" in the apis dashboard products tabs section

  @javascript
  Scenario: Filtering backends
    When I select the backends tab
    And I should see "My Fancy Backend API" in the apis dashboard backends tabs section
    And I should see "My Regular Backend API" in the apis dashboard backends tabs section
    Then I search for "My Fan" using the backends search bar
    And I should see "My Fancy Backend API" in the apis dashboard backends tabs section
    And I should not see "My Regular Backend API" in the apis dashboard backends tabs section
    Then I search for "My Foo Foo" using the backends search bar
    And I should not see "My Fancy Backend API" in the apis dashboard backends tabs section
    And I should not see "My Regular Backend API" in the apis dashboard backends tabs section
