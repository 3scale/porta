@javascript
Feature: Audience > Accounts > Edit

  Background:
    Given a provider is logged in
    And a buyer "Pepe" of the provider

  Scenario: Navigation
    Given they go to the provider dashboard
    When they follow "1 Account" in the audience dashboard widget
    And follow "Pepe"
    And follow "Edit"
    Then the current page is the buyer account edit page for "Pepe"

  Scenario: Editing an account
    Given they go to the buyer account edit page for "Pepe"
    When the form is submitted with:
      | Organization/Group Name | Pepito |
    Then the current page is the buyer account page for "Pepito"
    And should see the flash message "Account successfully updated"

  Scenario: Required fields and validation
    Given they go to the buyer account edit page for "Pepe"
    When the form is submitted with:
      | Organization/Group Name | |
    Then field "Organization/Group Name" has inline error "can't be blank"

  Scenario: Deleting an account
    Given a buyer "Deleteme" of the provider
    When they go to the buyer account edit page for "Deleteme"
    And follow "Delete" and confirm the dialog
    Then the current page is the buyer accounts page
    And they should see the flash message "The account was successfully deleted."
    And should see the following table:
      | Group/Org. |
      | Pepe       |
