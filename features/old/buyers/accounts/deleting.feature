@javascript
Feature: Deleting buyer account
  In order to remove a buyer
  As a provider
  I want to delete him/her

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"

  Scenario: Deleting buyer account from the account summary page
    When I go to the buyer account page for "bob"
    And I follow "Edit"
    And I follow "Delete" and I confirm dialog box
    Then I should be on the buyer accounts page
     And I should see "The account was successfully deleted."
     And I should not see "bob"


  Scenario: Cannot delete account if there are unsettled invoices
    Given provider "foo.3scale.localhost" is charging its buyers
    Given an invoice of buyer "bob" for January, 2011 with items:
      | name   | cost |
      | Custom |   42 |
     When I go to the buyer account page for "bob"
     And I follow "Edit"
     And I follow "Delete" and I confirm dialog box
     Then I should see "Invoices need to be settled before"
