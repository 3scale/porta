@javascript
Feature: CMS Redirects
  As a provider
  I want to CRUD redirects

  Background:
    Given a provider is logged in

  Scenario: Full CRUD Cycle on redirects
    When I go to the CMS new redirect page
    And I fill in the following:
      | Source | /from/Shire |
      | Target | /to/Mordor  |
    And I press "Create Redirect"
    Then I should see "Redirect created"
    When I follow "/from/Shire"
    And I fill in "Source" with "/from/Past"
    And I press "Update Redirect"
    Then I should see "Redirect updated"
    When I follow "Delete"
    And confirm the dialog
    Then I should see "Redirect deleted"
