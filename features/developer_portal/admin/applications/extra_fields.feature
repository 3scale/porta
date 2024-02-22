Feature: Developer portal application extra fields

  Background:
    Given a provider
    And the provider has the following fields defined for applications:
      | Name         | Choices | Required | Read only | Hidden |
      | description  |         |          |           |        |
      | engine       |         | true     |           |        |
      | wheels       | 1,2,3,4 | true     |           |        |
      | color        |         |          |           |        |
      | plate_number |         |          | true      |        |
      | stealth      |         |          |           | true   |
    And the default service of the provider has name "The API"
    And the following application plan:
      | Product | Name    | default |
      | The API | Default | true    |
    And a buyer "Jane" signed up to service "The API"
    And the buyer logs in

  Scenario: Show extra fields
    Given the following application:
      | Buyer | Name       | Product |
      | Jane  | Jane's App | The API |
    And the application has the following extra fields:
      | Engine       | foo     |
      | Wheels       | bar     |
      | Stealth      | bat     |
      | Plate number | edit me |
    When they go to the application's dev portal page
    Then they should see "Plate number"
    And should see "Engine"
    And should see "Wheels"
    But should not see "Stealth"

  Scenario: Extra fields are sorted by position
    Given provider "foo.3scale.localhost" has the field "wheels" for "Cinstance" in the position 20
    And the following application:
      | Buyer | Name       | Product |
      | Jane  | Jane's App | The API |
    And the application has the following extra fields:
      | Description | It's a car |
      | Engine      | 120        |
      | Wheels      | 4          |
      | Color       | White      |
    When they go to the application's dev portal page
    Then they should see the fields in order:
      | Description |
      | Engine      |
      | Color       |
      | Wheels      |
    But should not see the fields:
      | Plate number |
      | Stealth      |

  Scenario: Hidden and not editable extra fields should not be editable
    When they go to the dev portal new application page
    Then they should see the fields:
      | Description |
      | Engine      |
      | Wheels      |
      | Color       |
    But they should not see the fields:
      | Plate number |
      | Stealth      |

  Scenario: Extra fields validation
    When they go to the dev portal new application page
    And the form is submitted with:
      | Name        | Skoda    |
      | Description | Roomster |
      | Wheels      | 3        |
    Then field "Engine" has inline error "can't be blank"
    But field "Color" has no inline error

  Scenario: Create an application with extra fields
    When they go to the dev portal new application page
    And the form is submitted with:
      | Name        | Skoda         |
      | Description | Roomster      |
      | Wheels      | 3             |
      | Engine      | 1 Horse Power |
    Then they should see the flash message "Application was successfully created"
    And buyer "Jane" should have 1 cinstance

  Scenario: Edit an application with extra fields
    Given the following application:
      | Buyer | Name       | Product |
      | Jane  | Jane's App | The API |
    And the application has the following extra fields:
      | Engine       | foo     |
      | Wheels       | bar     |
      | Stealth      | bat     |
      | Plate number | edit me |
    When they go to the application's dev portal edit page
    Then the form is submitted with:
      | Engine | turbo |
      | Wheels | 2     |
    Then they should see the flash message "Application was successfully updated."
