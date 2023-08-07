Feature: Features :)
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
    Then I go to the edit page for plan "Basic"
    And I follow "New feature"
    And I fill in "Name" with "Free T-shirt"
    And I fill in "System name" with "tee"
    And I fill in "Description" with "T-shirt with logo of our company for free."
    And I press "Save"
    Then I should see "T-shirt with logo of our company for free."

  # TODO: Test that the "No features yet" notice dissapears when first feature is created,
  #       and appears when last one is deleted.
  @javascript
  Scenario: Disable a feature
    Given a service plan "Basic" of provider "foo.3scale.localhost"
    Given the provider has "service_plans" switch allowed
    And an enabled feature "50% more bugs" of provider "foo.3scale.localhost"

    When I log in as provider "foo.3scale.localhost"
    And I go to the service plans admin page
    And I follow "Basic"
    When I "disable" the feature "50% more bugs"
    Then I see feature "50% more bugs" is disabled

  @javascript
  Scenario: Enable a feature
    Given a service plan "Basic" of provider "foo.3scale.localhost"
    Given the provider has "service_plans" switch allowed
    And a feature "50% less bugs" of provider "foo.3scale.localhost"

    When I log in as provider "foo.3scale.localhost"
    And I go to the service plans admin page
    And I follow "Basic"
    When I "enable" the feature "50% less bugs"
    Then I see feature "50% less bugs" is enabled

  @javascript
  Scenario: Edit a feature
    Given a service plan "Basic" of provider "foo.3scale.localhost"
    And a feature "Magic" of provider "foo.3scale.localhost"

    When I log in as provider "foo.3scale.localhost"
    Then I go to the edit page for feature "Magic"
    Then I should see "Edit Feature"
    And I fill in "Name" with "More magic"
    And I press "Save"
    Then there is no feature named "Magic"
    And there is feature named "More magic"

  @javascript
  Scenario: Delete a feature
    Given the provider has "service_plans" switch allowed
    Given a service plan "Basic" for service "API" exists
    And a feature "Invulnerability" of provider "foo.3scale.localhost"

    When I log in as provider "foo.3scale.localhost"
    And I go to the service plans admin page
    Then I go to the edit page for admin service plan "Basic"
    And I press "Delete" and I confirm dialog box
