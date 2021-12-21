@javascript
Feature: Default plan
  In order to simplify the signup process of my clients
  As a provider
  I want to define a default plan

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a published application plan "Basic" of provider "foo.3scale.localhost"
    And a published application plan "Pro" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"

  Scenario: Marking plan as default
    When I log in as provider "foo.3scale.localhost"
    And I go to the application plans admin page
    And I select "Basic" as default plan
    Then I should see "Default plan was updated"
    And plan "Basic" should be the default

  Scenario: Changing default plan
    Given plan "Basic" is default
    When I log in as provider "foo.3scale.localhost"
    And I go to the application plans admin page
    And I select "Pro" as default plan
    Then I should see "Default plan was updated"
    And plan "Pro" should be the default

  Scenario: Hidden plan can be made default
    Given plan "Basic" is default
    And plan "Pro" is hidden
    When I log in as provider "foo.3scale.localhost"
    And I go to the application plans admin page
    Then I should see "Pro" in the default plans list
    And I select "Pro" as default plan
    Then I should see "Default plan was updated"
    And plan "Pro" should be the default

  Scenario: Selected plan doesn't exist
    Given a published application plan "Deleteme" of provider "foo.3scale.localhost"
    And plan "Basic" is default
    When I log in as provider "foo.3scale.localhost"
    And I go to the application plans admin page
    And plan "Deleteme" has been deleted
    And I select "Deleteme" as default plan
    Then I should see "The selected plan doesn't exist."
