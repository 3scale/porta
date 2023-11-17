@javascript
Feature: Audience > Accounts > New

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
    And fill in "Organization/Group Name" with "Pepito"
    And press "Update Account"
    Then they should see "Account: Pepito"
    # TODO: And they should see the flash message "Account updated or something"
    But should not see "Account: Pepe"

  Scenario: Deleting an account
    Given a buyer "Deleteme" of the provider
    When they go to the buyer account edit page for "Deleteme"
    And follow "Delete" and confirm dialog box
    Then the current page is the buyer accounts page
    And they should see the flash message "The account was successfully deleted."
    And should see the following table:
      | Group/Org. |
      | Pepe       |
