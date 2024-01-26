Feature: Developer portal edit application page

  Background:
    Given a provider
    And the provider has "multiple_services" visible
    And the provider has "service_plans" visible
    And a product "The API"
    And the following published application plans:
      | Product | Name       |
      | The API | Enterprise |
      | The API | Developer  |
    And a buyer "Jane" signed up to service "The API"
    And the buyer has an application "My App" with plan "Developer"
    And the buyer logs in

  Rule: Multiple applications disabled
    Background:
      Given the provider has "multiple_applications" denied

    Scenario: Navigation
      Given they go to the homepage
      When they follow "My App"
      And follow "Edit My App"
      Then the current page is the application's dev portal edit page

  Rule: Multiple applications enabled
    Background:
      Given the provider has "multiple_applications" allowed

    Scenario: Navigation
      Given they go to the dev portal applications page
      When they follow "My App"
      And follow "Edit My App"
      Then the current page is the application's dev portal edit page

    Scenario: Edit an application
      Given they go to the application's dev portal edit page
      When the form is submitted with:
        | Name        | Awesome App            |
        | Description | An awesome application |
      Then the current page is the application's dev portal page
      And they should see the flash message "Application was successfully updated"
      And should see the following details:
        | Name        | Awesome App            |
        | Description | An awesome application |

    @javascript
    Scenario: Delete an application
      Given they go to the application's dev portal edit page
      When they follow "Delete My App"
      And confirm the dialog
      Then the current page is the dev portal applications page
      And they should see the flash message "Application was successfully deleted."
      But should not see "My App"

    Scenario: Edit an application's extra fields
      Given the provider has the following fields defined for applications:
        | Label        | Required | Read only | Hidden |
        | Email        |          |           |        |
        | Phone number | true     |           |        |
        | UUID         |          | true      |        |
        | Secret sauce |          |           | true   |
      Given the buyer has an application "My App" for the product
      And the application has the following extra fields:
        | Phone number | 666-555-444 |
        | UUID         | 123         |
        | Secret sauce | Ketchup     |
      When they go to the application's dev portal edit page
      Then there is no field "UUID"
      And there is no field "Secret sauce"
      But there is a required field "Phone number"
      And there is a field "Phone number"
      And the form is submitted with:
        | Phone number | 999-888-777 |
      Then they should see the following details:
        | Email        |             |
        | Phone number | 999-888-777 |
        | UUID         | 123         |
        | Secret sauce | Ketchup     |
