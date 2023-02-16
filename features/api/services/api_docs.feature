Feature: ActiveDocs
  As a provider
  I want to manage my ActiveDocs

  Background:
    Given a provider is logged in

  @javascript
  Scenario Outline: Create a spec for the first time
    Given an admin wants to add a spec to a new service
    When they are reviewing the service's active docs
    And follow "Create your first spec"
    And submit the ActiveDocs form with <swagger version>
    Then they should see the new spec

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario: Index does not show the API column
    Given a service with a Swagger 2 spec
    When an admin is reviewing the service's active docs
    Then the table should not contain a column for the service

  @javascript 
  Scenario Outline: Autocomplete 
    Given a service with a <swagger version> spec
    When an admin is reviewing the spec
    And the swagger autocomplete should work for "user_key" with "user_keys"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      # | OAS 3.0         | Feature not implemented |

  @javascript
  Scenario Outline: Slashes generated curl command for header values
    Given a service with a <swagger version> spec
    When an admin is reviewing the spec
    Then <swagger version> should escape properly the curl string  

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      # | OAS 3.0         | Feature not implemented |

  @javascript
  Scenario Outline: Create a second spec
    Given a service with a <swagger version> spec
    And an admin is reviewing the service's active docs
    When follow "Create a new spec"
    And submit the ActiveDocs form with <swagger version>
    Then they should see the new spec

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         | 

  @javascript
  Scenario Outline: Update a spec
    Given a service with a <swagger version> spec
    And a service "New service"
    And an admin wants to update the spec
    When they try to update the spec with valid data
    Then they should see the updated spec

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         | 

  @javascript
  Scenario Outline: Form validation with invalid data
    Given a service with a <swagger version> spec
    And an admin wants to update the spec
    When they try to update the spec with invalid data 
    Then they should see the errors
    When they try to update the spec with an invalid Swagger version
    Then they should see the version is invalid
    And they try to update the spec with an invalid JSON spec 
    Then they should see the swagger is invalid

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         | 

  @javascript
  Scenario Outline: Go to the Edit page
    Given a service with a <swagger version> spec
    Then an admin can edit the spec

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         | 

  @javascript
  Scenario Outline: Hides and publishes a spec
    Given a service with a <swagger version> spec
    When an admin is reviewing the spec
    Then they can hide an publish the spec

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         | 

  @javascript
  Scenario Outline: Deletes a spec
    Given a service with a <swagger version> spec
    When an admin is reviewing the spec
    Then they can delete the spec 

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         | 

  @javascript
  Scenario Outline: Admin reviews a spec
    Given a service with a <swagger version> spec
    When an admin is reviewing the service's active docs
    Then they can review the spec

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         | 
