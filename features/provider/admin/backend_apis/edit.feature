@javascript
Feature: Backend API edit page

  Background:
    Given a provider is logged in

  Scenario: Edit an existing Backend API
    Given an admin wants to update a backend api
    Then they will be able to edit the name, description and base url
    But will not be able to edit its system name

  Scenario: Form validation
    Given an admin wants to update a backend api
    Then they will not be able to update it without a name
    And they will not be able to update it without a valid url

  Scenario: Edit a Backend API with duplicate fields
    Given an admin wants to update a backend api
    Then they will be able to update it with an existing name and url

  Scenario: Delete a Backend API used by product
    Given a backend api that is being used by a product
    When an admin wants to delete the backend api
    Then it is not possible to delete the backend

  Scenario: Delete a Backend API not used by any product
    Given a backend api that is not being used by any products
    When an admin wants to delete the backend api
    Then it is possible to delete the backend
