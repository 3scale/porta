@javascript
Feature: Product > ActiveDocs default form field values

  The ClearDefaultValuesPlugin should prevent swagger-ui from auto-filling
  form fields with any values, including explicit examples/defaults from the
  spec and auto-generated placeholders like "string" or 0.

  Background:
    Given a provider is logged in
    And a product
    And the product has an OAS 3.0 spec "User API" from fixture "user-api"


  Scenario: All form fields start empty regardless of spec examples
    When they go to the spec's preview page from Product context
    And they press "POST"
    And they press "Try it out"
    Then the request body field "name" should have value ""
    And the request body field "age" should have value ""
    And the request body field "email" should have value ""
    And the request body field "score" should have value ""
    And the request body field "active" should have value ""

  Scenario: Reset clears all fields to empty
    When they go to the spec's preview page from Product context
    And they press "POST"
    And they press "Try it out"
    And they fill in "name" with "John Doe"
    And they fill in "email" with "test@example.com"
    And they press "Reset"
    Then the request body field "name" should have value ""
    And the request body field "age" should have value ""
    And the request body field "email" should have value ""
    And the request body field "score" should have value ""
    And the request body field "active" should have value ""
