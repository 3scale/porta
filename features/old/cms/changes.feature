@javascript
Feature: CMS Changes
  As a provider
  I want to manage all not published CMS changes on one place

  Background:
    Given a provider is logged in

  Scenario: Changes
    Given I have changed CMS page "page"
    And I have changed CMS partial "partial"
    And I go to the CMS changes
    Then I should see 2 CMS changes

  Scenario: Revert page
    Given I have changed CMS page "Users"
    When I go to the CMS changes
    And I follow "Revert"
    Then they should see the flash message "Page \"Users\" reverted."
    And the CMS page "Users" should be reverted
