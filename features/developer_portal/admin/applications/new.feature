Feature: Developer portal new application page

  Background:
    Given a provider
    And the provider has "multiple_services" visible
    And the provider has "service_plans" visible
    And the default product of the provider has name "The API"
    And the following application plans:
      | Product | Name       | default |
      | The API | Developer  | true    |
      | The API | Enterprise |         |
    And a buyer "Jane" signed up to service "The API"
    And the buyer logs in

  Rule: Multiple applications enabled
    Background:
      Given the provider has "multiple_applications" visible

    Scenario: Navigation
      When they go to the homepage
      And they follow "Applications"
      And they follow "Create new application"
      Then the current page is the dev portal new application page

    Scenario: No published plans
      Given the product has no default application plan
      And the product has no published application plans
      When they go to the dev portal new application page
      Then they should see "No published plan"

    Scenario: When there are many subscriptions user need to choose one (NEW)
      Given another product "API 2"
      And the following published application plans:
        | Product | Name            |
        | API 2   | Some other plan |
      And the buyer is subscribed to product "API 2"
      When they go to the dev portal new application page
      Then the current page is the service selection page
      And they should see "The API"
      But they follow "API 2"
      Then the current page is product "API 2" dev portal new application page

    @javascript
    Scenario: Choose application plan on app creation, but no plans
      Given the product has no default application plan
      And the product allows to choose plan on app creation
      And the following service plan:
        | Product | Name     |
        | The API | Holidays |
      When they go to the dev portal new application page
      Then they should see "No published plan"

    @javascript
    Scenario: Choose application plan on app creation
      Given the following published application plans:
        | Product | Name   | Default |
        | The API | Silver | true    |
        | The API | Gold   |         |
      Given the product allows to choose plan on app creation
      And the following service plan:
        | Product | Name     |
        | The API | Holidays |
      When they go to the dev portal new application page
      And follow "Review/Change"
      And follow "Gold"
      And follow "Select this plan"
      And the form is submitted with:
        | Name        | My App                        |
        | Description | Awesome ultimate super widget |
      Then they should see the flash message "Application was successfully created"
      And should see the following details:
        | Name        | My App                        |
        | Description | Awesome ultimate super widget |
        | Plan        | Gold                          |
        | Status      | live                          |

    Scenario: Can't choose application plan on app creating
      Given the product has no default application plan
      And the product doesn't allow to choose plan on app creation
      And the following service plan:
        | Product | Name     |
        | The API | Holidays |
      When they go to the dev portal new application page
      Then there should not be a link to "Review/Change"

    Scenario: Create an application
      When they go to the dev portal new application page
      And the form is submitted with:
        | Name        | My App               |
        | Description | This is a mobile app |
      Then they should see the flash message "Application was successfully created"

    Scenario: Create an application that requires approval
      Given the following published application plan:
        | Product | Name   | Default | Approval required |
        | The API | Custom | True    | True              |
      When they go to the dev portal new application page
      And the form is submitted with:
        | Name        | MegaWidget  |
        | Description | Bla bla bla |
      Then they should see the following details:
        | Status | pending |
      And they should see "Your application is awaiting approval"

    Scenario: Create an application with extra fields
      Given the provider has the following fields defined for applications:
        | Label        | Required | Read only | Hidden |
        | Phone number | true     |           |        |
        | UUID         |          | true      |        |
        | Secret sauce |          |           | true   |
      And they go to the dev portal new application page
      Then there is no field "UUID"
      And there is no field "Secret sauce"
      But there is a required field "Phone number"
      When the form is submitted with:
        | Name | Cooking Mama |
      Then field "Phone number" has inline error "can't be blank"
      When the form is submitted with:
        | Name         | Cooking Mama |
        | Phone number | 666777888    |
      Then they should see the flash message "Application was successfully created"
      And should see the following details:
        | Phone number | 666777888 |

    Scenario: Product uses oauth
      Given the product uses backend oauth
      And they go to the homepage
      And there should not be a link to "API Access Details"
      When they follow "Applications" within the navigation bar
      And follow "Create new application"
      And the form is submitted with:
        | Name | Jane's App |
      Then they should see the flash message "Application was successfully created"
      And should be on application "Jane's App" dev portal page

  Rule: Multiple applications disabled
    Background:
      Given the provider has "multiple_applications" denied

    Scenario: Navigation
      When they go to the homepage
      And they follow "Create Application"
      Then the current page is the dev portal new application page

    Scenario: Can't create applications without published or default plans
      Given the provider has no published application plans
      And the provider has no default application plan
      When they go to the homepage
      And follow "Create Application"
      Then they should see "No published plan"

    Scenario: Create the one application
      Given they go to the dev portal new application page
      And the form is submitted with:
        | Name | Jane's App |
      Then they should see the flash message "Application was successfully created"
      And should be on application "Jane's App" dev portal page
