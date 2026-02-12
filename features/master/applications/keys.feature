@javascript
Feature: Application Keys management
  In order to control the way providers are using my API
  As master
  I want to manage their applications keys

  Background:
    Given a provider exists
    And master is the provider
    And master admin is logged in

  @ignore-backend
  Scenario: Regenerate provider key
    Given they are reviewing the provider's application details
    When follow "Regenerate"
    And confirm the dialog
    And fill in "Current password" with "superSecret1234#"
    And press "Confirm Password"
    And should see "You are now in super-user mode! Retry the action, please"
    And follow "Regenerate"
    And confirm the dialog
    Then should see "The key was successfully changed"

  Scenario: Set a custom app key
    Given they are reviewing the provider's application details
    When follow "Set a custom User Key" within the API Credentials card
    And fill in "Current password" with "superSecret1234#"
    And press "Confirm Password"
    And fill in "User key" with "new-valid-key"
    And press "Save"
    Then should see "new-valid-key" within the API Credentials card
    And should see "User key has been updated"
