Feature: Plan Features
  In order to list which features of my API are available for each plan
  As a provider
  I want to define features

  Background:
    Given a provider "foo.3scale.localhost"
    And an application plan "Basic" of provider "foo.3scale.localhost"
    Given current domain is the admin domain of provider "foo.3scale.localhost"

  @javascript
  Scenario: Create a feature
    When I log in as provider "foo.3scale.localhost"
    And I go to the edit page for plan "Basic"
    And I follow "New feature"
    And I fill in "Name" with "Free T-shirt"
    And I fill in "System name" with "tee"
    And I fill in "Description" with "T-shirt with logo of our company for free."
    And I press "Save"
    Then I should see "T-shirt with logo of our company for free."
    And I should see the flash message "Feature has been created."

  @javascript
  Scenario: "No features yet" notice disappears when the first feature is created, and appears when last one is deleted.
    When I log in as provider "foo.3scale.localhost"
    And I go to the edit page for plan "Basic"
    Then I should see "This plan has no features yet."

    When application plan "Basic" has "Some Feature" enabled
    And I go to the edit page for plan "Basic"
    Then I should not see "This plan has no features yet."

    When application plan "Basic" does not have any features
    And I go to the edit page for plan "Basic"
    Then I should see "This plan has no features yet."

  @javascript
  Scenario: Disable a feature
    Given application plan "Basic" has "Some Feature" enabled
    And I log in as provider "foo.3scale.localhost"
    And I go to the edit page for plan "Basic"
    And I disable the feature "Some Feature"
    Then I see the feature "Some Feature" is disabled
    And I should see the flash message "Feature has been disabled."

  @javascript
  Scenario: Enable a feature
    Given application plan "Basic" has "Some Feature" disabled
    And I log in as provider "foo.3scale.localhost"
    And I go to the edit page for plan "Basic"
    When I enable the feature "Some Feature"
    Then I see the feature "Some Feature" is enabled
    And I should see the flash message "Feature has been enabled."

  @javascript
  Scenario: Edit a feature
    Given application plan "Basic" has "Some Feature" enabled
    When I log in as provider "foo.3scale.localhost"
    And I go to the edit page for plan "Basic"
    And I click "Edit" for the feature "Some Feature"
    Then I should see "Edit Feature"
    And I fill in "Name" with "Another Feature"
    And I press "Save"
    Then I see the feature "Another Feature" is enabled
    And I should not see "Some Feature"
    And I should see the flash message "Feature has been updated."

  @javascript
  Scenario: Delete a feature
    Given application plan "Basic" has "Some Feature" enabled
    When I log in as provider "foo.3scale.localhost"
    And I go to the edit page for plan "Basic"
    And I click "Delete" for the feature "Some Feature" and I confirm dialog box
    Then I should not see "Some Feature"
    And I should see the flash message "Feature has been deleted."
