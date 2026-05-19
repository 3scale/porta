@javascript
Feature: Product > ActiveDocs default form field values

  The ClearDefaultValuesPlugin should prevent swagger-ui from auto-filling
  form fields with generated values like "string" or 0, while preserving
  explicit examples and defaults defined in the spec.

  Background:
    Given a provider is logged in
    And a product
    And the product has an OAS 3.0 spec "User API" from fixture "user-api"


  Scenario: Initial form field values respect spec defaults
    When they go to the spec's preview page from Product context
    And they press "POST"
    And they press "Try it out"
    Then the request body field "name" should have value "Jane Doe"
    And the request body field "age" should have value "30"
    And the request body field "email" should have value ""
    And the request body field "score" should have value ""
    And the request body field "active" should have value ""

  Scenario: Reset restores spec defaults and clears generated values
    When they go to the spec's preview page from Product context
    And they press "POST"
    And they press "Try it out"
    And they fill in "email" with "test@example.com"
    And they press "Reset"
    Then the request body field "name" should have value "Jane Doe"
    And the request body field "age" should have value "30"
    And the request body field "email" should have value ""
    And the request body field "score" should have value ""
    And the request body field "active" should have value ""
