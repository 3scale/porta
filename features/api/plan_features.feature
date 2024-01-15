Feature: Plan Features
  In order to list which features of my API are available for each plan
  As a provider
  I want to define features

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And an application plan "Basic" of provider "foo.3scale.localhost"
    And application plan "Basic" has "Some Feature" enabled

  @javascript
  Scenario: Create a feature
    Given I go to the edit page for plan "Basic"
    And I follow "New feature"
    And I fill in "Name" with "Free T-shirt"
    And I fill in "System name" with "tee"
    And I fill in "Description" with "T-shirt with logo of our company for free."
    When I press "Save"
    Then I should see "T-shirt with logo of our company for free."
    And I should see the flash message "Feature has been created."

  @javascript
  Scenario: "No features yet" notice is shown when the plan doesn't have features
    Given application plan "Basic" does not have any features
    When I go to the edit page for plan "Basic"
    Then I should see "This plan has no features yet."

  @javascript
  Scenario: "No features yet" notice disappears when the plan has features
    When I go to the edit page for plan "Basic"
    Then I should not see "This plan has no features yet."

  @javascript
  Scenario: Disable a feature
    Given I go to the edit page for plan "Basic"
    When I disable the plan feature "Some Feature"
    Then I see the plan feature "Some Feature" is disabled
    And I should see the flash message "Feature has been disabled."

  @javascript
  Scenario: Enable a feature
    Given application plan "Basic" has "Another Feature" disabled
    And I go to the edit page for plan "Basic"
    When I enable the plan feature "Another Feature"
    Then I see the plan feature "Another Feature" is enabled
    And I should see the flash message "Feature has been enabled."

  @javascript
  Scenario: Edit a feature
    Given I go to the edit page for plan "Basic"
    And I click "Edit" for the plan feature "Some Feature"
    And I fill in "Name" with "Another Feature"
    When I press "Save"
    Then I see the plan feature "Another Feature" is enabled
    And I should not see "Some Feature"
    And I should see the flash message "Feature has been updated."

  @javascript
  Scenario: Delete a feature
    Given I go to the edit page for plan "Basic"
    When I click "Delete" for the plan feature "Some Feature" and confirm the dialog
    Then I should not see "Some Feature"
    And I should see the flash message "Feature has been deleted."
