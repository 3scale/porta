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
    When I navigate to the default application of the provider
    And I follow "Regenerate" and I confirm dialog box
    And I enter the admin password in "Current password"
    Then I should see "You are now in super-user mode! Retry the action, please."
    And I follow "Regenerate" and I confirm dialog box
    And I should see "The key was successfully changed"
