@javascript
Feature: Application edit page

  Background:
    Given a provider is logged in
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the following application:
      | Buyer | Name   | Product |
      | Jane  | My App | My API  |

  Scenario: Navigation
    Given they go to the application's admin page
    When they follow "Edit"
    Then the current page is the application's admin edit page

  Scenario: Name can't be blank
    Given they go to the application's admin edit page
    When the form is submitted with:
      | Name |  |
    Then field "Name" has inline error "can't be blank"

  Scenario: Editing an application
    Given they go to the application's admin edit page
    When the form is submitted with:
      | Name | Cool App |
    Then they should see the flash message "Application was successfully updated"
    And the current page is the application's admin page

  Scenario: Editting an application with extra fields
    Given the provider has the following fields defined for applications:
      | name                | required | read_only | hidden |
      | app_extra_required  | true     |           |        |
      | app_extra_read_only |          | true      |        |
      | app_extra_hidden    |          |           | true   |
    And they go to the application's admin edit page
    When the form is submitted with:
      | Name             | Banana App  |
      | App extra hidden | habba babba |
    Then they should see the flash message "Application was successfully updated"
    And they should see "habba babba" within the application details

  Scenario: Delete application
    Given they go to the application's admin edit page
    When follow "Delete"
    And confirm the dialog
    Then they should see the flash message "The application was successfully deleted."
    And there should be 1 application cancelled event
    # FIXME: And all the events should be valid
    And the current page is the admin portal applications page
