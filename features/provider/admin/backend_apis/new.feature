@javascript
Feature: Backend API new page

  Background:
    Given a provider is logged in

  Scenario: Navigation from Dashboard widget
    Given the current page is the provider dashboard
    When they follow "Create Backend" within the apis dashboard widget
    Then the current page is the admin portal new backend api page

  Scenario: Navigation from context selector
    Given the current page is the provider dashboard
    When they select "Backends" from the context selector
    And follow "Create a backend"
    Then the current page is the admin portal new backend api page

  Scenario: Create a new Backend API
    Given they go to the admin portal new backend api page
    When the form is submitted with:
      | Name             | My Backend                 |
      | System name      | my-backend                 |
      | Description      | This is my new backend API |
      | Private Base URL | http://api.example.org     |
    Then they should see a toast alert with text "Backend created"
    And the current page is the admin portal overview page of backend "My Backend"

  Scenario: The form won't be submitted without Name and URL
    Given they go to the admin portal new backend api page
    When the form is submitted with:
      | Name             | My Backend |
      | Private Base URL |            |
    And the current page is the admin portal new backend api page
    When the form is submitted with:
      | Name             |                             |
      | Private Base URL | https://backend.example.org |
    And the current page is the admin portal new backend api page
    But the form is submitted with:
      | Name             | My Backend                  |
      | Private Base URL | https://backend.example.org |
    Then they should see a toast alert with text "Backend created"
    And the current page is the admin portal overview page of backend "My Backend"

  Scenario: System name is invalid
    Given they go to the admin portal new backend api page
    When the form is submitted with:
      | Name             | My Backend                  |
      | System name      | '$                          |
      | Private Base URL | https://backend.example.org |
    Then they should see a toast alert with text "Backend could not be created"
    And field "System name" has inline error "invalid"

  Scenario: System name is in use
    Given the provider has the following backend api:
      | Name             | My Backend                  |
      | System name      | backend-api                 |
      | Private Base URL | https://backend.example.org |
    Given they go to the admin portal new backend api page
    When the form is submitted with:
      | Name             | My Other Backend              |
      | System name      | backend-api                   |
      | Private Base URL | https://backend-2.example.org |
    Then they should see a toast alert with text "Backend could not be created"
    Then field "System name" has inline error "has already been taken"
