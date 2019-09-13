@javascript @selenium
Feature: ActiveDocs
  In order to rule the world
  As a provider I wanna provide swagger

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has the swagger example of signup
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

  Scenario: Upload Swagger 2.0
    When I go to the new active docs page
    And I fill in the following:
      | Name          | MegaAPI  |
      | System name   | ubermega |
    And I fill in the API JSON Spec with:
    """
    {
        "swagger":"2.0",
        "info":{
            "title":"Product API",
            "version":"2.1"
        },
        "paths":{
            "/products":{
                "get":{
                    "summary":"List All Porducts",
                    "description":"Products Endpoint where Porducts happen",
                    "responses": {
                     "200": {
                       "description": "OK"
                     }
                    }
                }
            }
        }
    }
    """
    And I press "Create Service"
    Then I should see "ActiveDocs Spec was successfully saved."
    And I should see "Product API"

  Scenario: CRUD -- Index / Edit / Update / Preview
    When I go to the provider active docs page
    Then I should see "ActiveDocs"
    When I follow "Edit" within the row for echo active docs
    Then I should see "Edit Service Spec"
    And I press "Update Service"
    Then I should see "ActiveDocs Spec was successfully updated."

  Scenario: CRUD -- Create / Publish / Hide / Delete
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
    {"swaggerVersion":"1.2", "basePath": "https://echo-api.3scale.net", "apis":[]}
    """
    And I press "Create Service"
    Then I should see "ActiveDocs Spec was successfully saved."
    When I follow "Publish"
    Then I should see "Spec UberAPI published"
    And I follow "Hide"
    Then I should see "Spec UberAPI unpublished"
    When I delete the API Spec
    Then I should see "ActiveDocs Spec was successfully deleted."

  Scenario: Swagger 1.2 and autocomplete
    When I go to the new active docs page
    And I fill in the following:
      | Name          | UberAPI  |
      | System name   | uberdoze |
    And I fill in the API JSON Spec with:
    """
{
 "basePath": "https://hello-world-api.3scale.net",
 "apiVersion": "v1",
 "swaggerVersion": "1.2",
 "apis": [
   {
     "path": "/",
     "operations": [
       {
         "method": "GET",
         "summary": "Say Hello!",
         "description": "This operation says hello.",
         "nickname": "hello",
         "group": "words",
         "type": "string",
         "parameters": [
           {
             "name": "user_key",
             "description": "Your API access key",
             "type": "string",
             "paramType": "query",
             "threescale_name": "user_keys"
           }
         ]
       }
     ]
   }
 ]
}
    """
    And I press "Create Service"
    Then I should see "ActiveDocs Spec was successfully saved."
    And the swagger autocomplete should work for "user_key" with "user_keys"


  Scenario: Swagger 2.0 and autocomplete
    When I go to the new active docs page
    And I fill in the following:
      | Name          | UberAPI  |
      | System name   | uberdoze |
    And I fill in the API JSON Spec with:
    """
{
   "swagger": "2.0",
   "info": {
       "version": "1.0",
       "title": "Hello World"
   },
   "host": "hello-world-api.3scale.net",
   "basePath": "/",
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
                       "type": "string"
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
    And the swagger autocomplete should work for "user_key" with "user_keys"

  Scenario: Swagger 2.0 and slashes generated curl command for header values
    When I go to the new active docs page
    And I fill in the following:
      | Name          | UberAPI  |
      | System name   | uberdoze |
    And I fill in the API JSON Spec with:
    """
{
   "swagger": "2.0",
   "info": {
       "version": "1.0",
       "title": "Hello World"
   },
   "host": "hello-world-api.3scale.net",
   "basePath": "/",
   "paths": {
       "/": {
           "get": {
               "summary": "Say Hello!",
               "description": "This operation says hello",
               "parameters": [
                   {
                       "name": "user_key",
                       "in": "header",
                       "description": "Your API access key",
                       "required": true,
                       "type": "string"
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
    And swagger should escape properly the curl string
