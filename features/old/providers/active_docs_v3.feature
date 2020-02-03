@javascript
Feature: ActiveDocs
  In order to rule the world
  As a provider I wanna provide swagger

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has the oas3 simple example
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

  Scenario: Upload OAS 3.0
    When I go to the new active docs page
    And I fill in the following:
      | Name          | MegaAPI  |
      | System name   | ubermega |
    And I fill in the API JSON Spec with:
    """
    {
      "openapi": "3.0.0",
      "info": {
        "title": "Simple API overview",
        "version": "3.0.0"
      },
      "paths": {
        "/": {
          "get": {
            "summary": "Gives info about the api",
            "description": "Info Endpoint",
            "responses": {
              "200": {
                "description": "OK",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """
    And I press "Create Service"
    Then I should see "ActiveDocs Spec was successfully saved."
    And I should see "Simple API overview"

  Scenario: CRUD -- Create / Publish / Hide / Delete -- OAS 3
    When I go to the new active docs page
    And I fill in the following:
      | Name          | UberAPI  |
      | System name   | uberdoze |
    And I fill in the API JSON Spec with:
    """
    {"name":"godzilla"}
    """
    And I press "Create Service"
    Then I should see "JSON Spec is invalid"
    When I fill in the API JSON Spec with:
    """
    {
      "openapi": "3.0.0",
      "info": {
        "title": "Simple API overview",
        "version": "3.0.0"
      },
      "paths": {
        "/": {
          "get": {
            "summary": "Gives info about the api",
            "description": "Info Endpoint",
            "responses": {
              "200": {
                "description": "OK",
                "content": {
                  "application/json": {
                    "schema": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """
    And I press "Create Service"
    Then I should see "ActiveDocs Spec was successfully saved."
    When I follow "Publish"
    Then I should see "Spec UberAPI published"
    And I follow "Hide"
    Then I should see "Spec UberAPI unpublished"
    When I delete the API Spec
    Then I should see "ActiveDocs Spec was successfully deleted."

  # TODO: feature not supported. Wait for plugins.
  @wip
  Scenario: OAS 3 and autocomplete
    When I go to the new active docs page
    And I fill in the following:
      | Name          | UberAPI  |
      | System name   | uberdoze |
    And I fill in the API JSON Spec with:
    """
    {
      "openapi": "3.0.0",
      "info": {
        "version": "3.0",
        "title": "Hello World"
      },
      "paths": {
        "/": {
          "get": {
            "summary": "Say Hello!",
            "description": "This operation says hello",
            "parameters": [
              {
                "name": "user_key",
                "x-data-threescale-name": "user_keys",
                "in": "query",
                "description": "Your API access key",
                "required": true,
                "schema": {
                  "type": "string"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Hello!"
              }
            }
          }
        }
      }
    }
    """
    And I press "Create Service"
    Then should see "ActiveDocs Spec was successfully saved."
    And the swagger v3 autocomplete should work for "user_key" with "user_keys"

  # TODO: feature not supported. Wait for plugins.
  @wip
  Scenario: OAS 3 and slashes generated curl command for header values
    When I go to the new active docs page
    And I fill in the following:
      | Name          | UberAPI  |
      | System name   | uberdoze |
    And I fill in the API JSON Spec with:
    """
    {
      "openapi": "3.0.0",
      "info": {
        "version": "3.0",
        "title": "Hello World"
      },
      "paths": {
        "/": {
          "get": {
            "summary": "Say Hello!",
            "description": "This operation says hello",
            "parameters": [
              {
                "name": "user_key",
                "x-data-threescale-name": "user_keys",
                "in": "header",
                "description": "Your API access key",
                "required": true,
                "schema": {
                  "type": "string"
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Hello!"
              }
            }
          }
        }
      }
    }
    """
    And I press "Create Service"
    Then should see "ActiveDocs Spec was successfully saved."
    And swagger v3 should escape properly the curl string
