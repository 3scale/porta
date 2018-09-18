Feature: Features :)
  In order to list which features of my API are available for each plan
  As a provider
  I want to define features

  Background:
    Given a provider "foo.example.com"
    And an application plan "Basic" of provider "foo.example.com"
    Given current domain is the admin domain of provider "foo.example.com"

  @javascript @wip
  Scenario: Create a feature
    When I log in as provider "foo.example.com"
    And I go to the edit page for plan "Basic"
    And I follow "New feature"
    And I fill in "Name" with "Free T-shirt"
    And I fill in "Description" with "T-shirt with logo of our company for free."
    And I press "Create Feature"
    Then I should see enabled feature "Free T-shirt"
    And provider "foo.example.com" should have feature "Free T-shirt"
    And feature "Free T-shirt" should be enabled for plan "Basic"

  # TODO: Test that the "No features yet" notice dissapears when first feature is created,
  #       and appears when last one is deleted.

  @javascript @wip
  Scenario: Disable a feature
    Given a feature "50% less bugs" of provider "foo.example.com"
    And feature "50% less bugs" is enabled for plan "Basic"
    When I log in as provider "foo.example.com"
    And I go to the edit page for plan "Basic"
    And I press the disable button for feature "50% less bugs"
    Then I should see disabled feature "50% less bugs"
    And feature "50% less bugs" should be disabled for plan "Basic"

  @javascript @wip
  Scenario: Enable a feature
    Given a feature "Light-speed connection" of provider "foo.example.com"
    And feature "Light-speed connection" is disabled for plan "Basic"
    When I log in as provider "foo.example.com"
    And I go to the edit page for plan "Basic"
    And I press the enable button for feature "Light-speed connection"
    Then I should see enabled feature "Light-speed connection"
    And feature "Light-speed connection" should be enabled for plan "Basic"

  @javascript @wip
  Scenario: Edit a feature
    Given a feature "Magic" of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the edit page for plan "Basic"
    And I follow "Edit" for feature "Magic"
    And I fill in "Name" with "More magic"
    And I press "Update Feature"
    Then I should see feature "More magic"
    And provider "foo.example.com" should have feature "More magic"
    But provider "foo.example.com" should not have feature "Magic"

  @javascript @wip
  Scenario: Delete a feature
    Given a feature "Invulnerability" of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the edit page for plan "Basic"
    And I press "Delete" for feature "Invulnerability" and I confirm dialog box
    Then I should not see feature "Invulnerability"
    And provider "foo.example.com" should not have feature "Invulnerability"

