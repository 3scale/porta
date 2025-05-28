@javascript
Feature: Provider Admin Access tokens

  As an admin I want to be able to read, create and edit access tokens

  Background:
    Given a provider is logged in
    And they go to the provider personal page

  Rule: Index page
    Background:
      Given the provider has the following access tokens:
        | Name   | Scopes        | Permission   |
        | Potato | Analytics API | Read Only    |
        | Banana | Billing API   | Read & Write |
      And they go to the personal tokens page

    Scenario: Navigation to index page
      Given they go to the provider dashboard
      When they select "Account Settings" from the context selector
      And press "Personal" within the main menu
      And follow "Tokens" within the main menu's section Personal
      Then the current page is the personal tokens page

    Scenario: Tokens are listed in a table
      Then the table should contain the following:
        | Name   | Scopes        | Expiration     | Permission   |
        | Potato | Analytics API | Never expires  | Read Only    |
        | Banana | Billing API   | Never expires  | Read & Write |

  Rule: New page
    Background:
      Given they go to the new access token page

    Scenario: Navigation to the new page
      Given they go to the personal tokens page
      When they follow "Add Access Token"
      Then the current page is the new access token page

    Scenario: New access token required fields
      When the current page is the new access token page
      Then there is a required field "Name"
      And there is a required field "Scopes"
      And there is a required field "Permission"
      And there is a required field "Expires in"
      And the submit button is enabled

    Scenario: Create access tokens without required fields
      When they press "Create Access Token"
      Then field "Name" has inline error "can't be blank"
      And field "Scopes" has inline error "select at least one scope"
      And field "Permission" has no inline error
      And field "Expires in" has no inline error

    Scenario: Create access token
      When they press "Create Access Token"
      And the form is submitted with:
        | Name          | LeToken       |
        | Analytics API | Yes           |
        | Permission    | Read & Write  |
        | Expires in    | No expiration |
      Then the current page is the personal tokens page
      And they should see a toast alert with text "Access token was successfully created"
      And should see the following details:
        | Name       | LeToken        |
        | Scopes     | Analytics API  |
        | Permission | Read & Write   |
        | Expires at | Never expires  |
      And there should be a link to "I have copied the token"

  Rule: Edit page
    Background:
      Given the provider has the following access tokens:
        | Name    | Scopes                     | Permission | Expires at            |
        | LeToken | Billing API, Analytics API | Read Only  | 2030-01-01T00:00:00Z  |
      And they go to the access token's edit page

    Scenario: Navigation to edit page
      Given they go to the personal tokens page
      When they follow "Edit" in the 1st row within the access tokens table
      Then the current page is the access token's edit page

    Scenario: Edit access token
      When the form is submitted with:
        | Name        | New Token Name |
        | Billing API | No             |
        | Permission  | Read & Write   |
      Then they should see a toast alert with text "Access token was successfully updated"
      Then the table should contain the following:
        | Name           | Scopes        | Permission   |
        | New Token Name | Analytics API | Read & Write |

    Scenario: Edit access tokens without required fields
      When the form is submitted with:
        | Name |  |
      Then field "Name" has inline error "can't be blank"

    Scenario: Delete access token
      Given the current page is access token "LeToken" edit page
      When they follow "Delete"
      And confirm the dialog
      Then the current page is the personal tokens page
      And they should see a toast alert with text "Access token was successfully deleted"
      But should not see "LeToken"
