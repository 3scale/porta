Feature: ActiveDocs
  As a provider
  I want to manage my ActiveDocs

  Background:
    Given a provider is logged in

  @javascript
  Scenario: Create a spec for the first time
    Given an admin wants to add a spec to a new service
    When they are reviewing the service's active docs
    And follow "Create your first spec"
    And submit the ActiveDocs form
    Then they should see the new spec

  @javascript
  Scenario: Create a second spec
    Given a service with a spec
    And an admin is reviewing the service's active docs
    When follow "Create a new spec"
    And submit the ActiveDocs form
    Then they should see the new spec

  @javascript
  Scenario: Update a spec
    Given a service with a spec
    And a service "New service"
    And an admin wants to update the spec
    When they try to update the spec with valid data
    Then they should see the updated spec

  @javascript
  Scenario: Form validation with invalid data
    Given a service with a spec
    And an admin wants to update the spec
    When they try to update the spec with invalid data 
    Then they should see the errors

  @javascript
  Scenario: Go to the Edit page
    Given a service with a spec
    Then an admin can edit the spec

  @javascript
  Scenario: Hides and publishes a spec
    Given a service with a spec
    When an admin is reviewing the spec
    Then they can hide an publish the spec

  @javascript
  Scenario: Deletes a spec
    Given a service with a spec
    When an admin is reviewing the spec
    Then they can delete the spec 

  @javascript
  Scenario: Admin reviews a spec
    Given a service with a spec
    When an admin is reviewing the service's active docs
    Then they can review the spec

#   Scenario: Swagger 1.2 and autocomplete
#     When I go to the new active docs page
#     And I fill in the following:
#       | Name          | UberAPI  |
#       | System name   | uberdoze |
#     And I fill in the API JSON Spec with:
#     """
# {
#  "basePath": "https://hello-world-api.3scale.net",
#  "apiVersion": "v1",
#  "swaggerVersion": "1.2",
#  "apis": [
#    {
#      "path": "/",
#      "operations": [
#        {
#          "method": "GET",
#          "summary": "Say Hello!",
#          "description": "This operation says hello.",
#          "nickname": "hello",
#          "group": "words",
#          "type": "string",
#          "parameters": [
#            {
#              "name": "user_key",
#              "description": "Your API access key",
#              "type": "string",
#              "paramType": "query",
#              "threescale_name": "user_keys"
#            }
#          ]
#        }
#      ]
#    }
#  ]
# }
#     """
#     And I press "Create Spec"
#     Then I should see "ActiveDocs Spec was successfully saved."
#     And the swagger autocomplete should work for "user_key" with "user_keys"


#   Scenario: Swagger 2.0 and autocomplete
#     When I go to the new active docs page
#     And I fill in the following:
#       | Name          | UberAPI  |
#       | System name   | uberdoze |
#     And I fill in the API JSON Spec with:
#     """
# {
#    "swagger": "2.0",
#    "info": {
#        "version": "1.0",
#        "title": "Hello World"
#    },
#    "host": "hello-world-api.3scale.net",
#    "basePath": "/",
#    "paths": {
#        "/": {
#            "get": {
#                "summary": "Say Hello!",
#                "description": "This operation says hello",
#                "parameters": [
#                    {
#                        "name": "user_key",
#                        "x-data-threescale-name": "user_keys",
#                        "in": "query",
#                        "description": "Your API access key",
#                        "required": true,
#                        "type": "string"
#                    }
#                ],
#                "responses": {
#                    "200": {
#                        "description": "Hello!"
#                    }
#                }
#            }
#        }
#    }
# }
#     """
#     And I press "Create Spec"
#     Then should see "ActiveDocs Spec was successfully saved."
#     And the swagger autocomplete should work for "user_key" with "user_keys"

#   Scenario: Swagger 2.0 and slashes generated curl command for header values
#     When I go to the new active docs page
#     And I fill in the following:
#       | Name          | UberAPI  |
#       | System name   | uberdoze |
#     And I fill in the API JSON Spec with:
#     """
# {
#    "swagger": "2.0",
#    "info": {
#        "version": "1.0",
#        "title": "Hello World"
#    },
#    "host": "hello-world-api.3scale.net",
#    "basePath": "/",
#    "paths": {
#        "/": {
#            "get": {
#                "summary": "Say Hello!",
#                "description": "This operation says hello",
#                "parameters": [
#                    {
#                        "name": "user_key",
#                        "in": "header",
#                        "description": "Your API access key",
#                        "required": true,
#                        "type": "string"
#                    }
#                ],
#                "responses": {
#                    "200": {
#                        "description": "Hello!"
#                    }
#                }
#            }
#        }
#    }
# }
#     """
#     And I press "Create Spec"
#     Then should see "ActiveDocs Spec was successfully saved."
#     And swagger should escape properly the curl string

# # @javascript
# # Feature: ActiveDocs
# #   In order to rule the world
# #   As a provider I wanna provide swagger

# #   Background:
# #     Given a provider "foo.3scale.localhost"
# #     And provider "foo.3scale.localhost" has the oas3 simple example
# #     And current domain is the admin domain of provider "foo.3scale.localhost"
# #     And I log in as provider "foo.3scale.localhost"

#   Scenario: Upload OAS 3.0
#     When I go to the new active docs page
#     And I fill in the following:
#       | Name          | MegaAPI  |
#       | System name   | ubermega |
#     And I fill in the API JSON Spec with:
#     """
#     {
#       "openapi": "3.0.0",
#       "info": {
#         "title": "Simple API overview",
#         "version": "3.0.0"
#       },
#       "paths": {
#         "/": {
#           "get": {
#             "summary": "Gives info about the api",
#             "description": "Info Endpoint",
#             "responses": {
#               "200": {
#                 "description": "OK",
#                 "content": {
#                   "application/json": {
#                     "schema": {
#                       "type": "string"
#                     }
#                   }
#                 }
#               }
#             }
#           }
#         }
#       }
#     }
#     """
#     And I press "Create Spec"
#     Then I should see "ActiveDocs Spec was successfully saved."
#     And I should see "Simple API overview"

#   Scenario: CRUD -- Create / Publish / Hide / Delete -- OAS 3
#     When I go to the new active docs page
#     And I fill in the following:
#       | Name          | UberAPI  |
#       | System name   | uberdoze |
#     And I fill in the API JSON Spec with:
#     """
#     {"name":"godzilla"}
#     """
#     And I press "Create Spec"
#     Then I should see "JSON Spec is invalid"
#     When I fill in the API JSON Spec with:
#     """
#     {
#       "openapi": "3.0.0",
#       "info": {
#         "title": "Simple API overview",
#         "version": "3.0.0"
#       },
#       "paths": {
#         "/": {
#           "get": {
#             "summary": "Gives info about the api",
#             "description": "Info Endpoint",
#             "responses": {
#               "200": {
#                 "description": "OK",
#                 "content": {
#                   "application/json": {
#                     "schema": {
#                       "type": "string"
#                     }
#                   }
#                 }
#               }
#             }
#           }
#         }
#       }
#     }
#     """
#     And I press "Create Spec"
#     Then I should see "ActiveDocs Spec was successfully saved."
#     When I follow "Publish"
#     Then I should see "Spec UberAPI published"
#     And I follow "Hide"
#     Then I should see "Spec UberAPI unpublished"
#     When I delete the API Spec
#     Then I should see "ActiveDocs Spec was successfully deleted."

#   # TODO: feature not supported. Wait for plugins.
#   @wip
#   Scenario: OAS 3 and autocomplete
#     When I go to the new active docs page
#     And I fill in the following:
#       | Name          | UberAPI  |
#       | System name   | uberdoze |
#     And I fill in the API JSON Spec with:
#     """
#     {
#       "openapi": "3.0.0",
#       "info": {
#         "version": "3.0",
#         "title": "Hello World"
#       },
#       "paths": {
#         "/": {
#           "get": {
#             "summary": "Say Hello!",
#             "description": "This operation says hello",
#             "parameters": [
#               {
#                 "name": "user_key",
#                 "x-data-threescale-name": "user_keys",
#                 "in": "query",
#                 "description": "Your API access key",
#                 "required": true,
#                 "schema": {
#                   "type": "string"
#                 }
#               }
#             ],
#             "responses": {
#               "200": {
#                 "description": "Hello!"
#               }
#             }
#           }
#         }
#       }
#     }
#     """
#     And I press "Create Spec"
#     Then should see "ActiveDocs Spec was successfully saved."
#     And the swagger v3 autocomplete should work for "user_key" with "user_keys"

#   # TODO: feature not supported. Wait for plugins.
#   @wip
#   Scenario: OAS 3 and slashes generated curl command for header values
#     When I go to the new active docs page
#     And I fill in the following:
#       | Name          | UberAPI  |
#       | System name   | uberdoze |
#     And I fill in the API JSON Spec with:
#     """
#     {
#       "openapi": "3.0.0",
#       "info": {
#         "version": "3.0",
#         "title": "Hello World"
#       },
#       "paths": {
#         "/": {
#           "get": {
#             "summary": "Say Hello!",
#             "description": "This operation says hello",
#             "parameters": [
#               {
#                 "name": "user_key",
#                 "x-data-threescale-name": "user_keys",
#                 "in": "header",
#                 "description": "Your API access key",
#                 "required": true,
#                 "schema": {
#                   "type": "string"
#                 }
#               }
#             ],
#             "responses": {
#               "200": {
#                 "description": "Hello!"
#               }
#             }
#           }
#         }
#       }
#     }
#     """
#     And I press "Create Spec"
#     Then should see "ActiveDocs Spec was successfully saved."
#     And swagger v3 should escape properly the curl string
