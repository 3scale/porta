@javascript
Feature: Backend API new page

  Background:
    Given a provider is logged in

  Scenario: Create a new Backend API
    When an admin goes to the backend apis page
    And they create a new backend api
    Then they are redirected to the new backend api overview page

  Scenario: Form validation
    When an admin is creating a new backend api
    Then it is not possible to create it without a name, a valid url or system name
    But it is possible to create it without system name

  Scenario: Create a Backend API with duplicate fields
    Given a backend
    When an admin is creating a new backend api
    Then it is possible to create it using the same name and url
    But it is not possible to use the same system name
