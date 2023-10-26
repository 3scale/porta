@javascript
Feature: Backend Usages
  In order to manage my Backends
  As a provider
  I want to see a menu that lets me add Backends to a Product

  Background:
    Given a provider is logged in

  Scenario: Empty state
    Given a product with no backends
    When an admin goes to the product's backend usages page
    Then should see "There are no backends yet"
    And they can create a backend from there

  Scenario: Add a backend API
    Given a backend
    And a product
    When an admin goes to the product's backend usages page
    Then they can add the backend by filling up the form
    And the product will be using this backend

  Scenario: A backend can be used by each product once
    Given a product
    And a backend
    And the backend is used by this product
    When an admin goes to the product's backend usages page
    And they try to add the backend again
    Then the backend won't be available

  Scenario: Add a backend with wrong path
    Given a backend
    And a product
    When an admin goes to the product's backend usages page
    Then they can't add the backend with an invalid path

  Scenario: Add a backend must be accessible
    Given a product
    And a backend
    But the backend is unavailable
    When an admin goes to the product's backend usages page
    And they try to add the backend
    Then the backend won't be available
