Feature: Default plan
  In order to simplify the signup process of my clients
  As a provider
  I want to define a default plan

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And a published application plan "Basic" of provider "foo.example.com"
    And a published application plan "Pro" of provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"

  @javascript
  Scenario: Marking plan as default
    When I log in as provider "foo.example.com"
    And I go to the application plans admin page
    And I select "Basic" as default plan
    Then I should see "Default plan was updated"
    And plan "Basic" should be the default

  @javascript
  Scenario: Changing default plan
    Given plan "Basic" is default
    When I log in as provider "foo.example.com"
    And I go to the application plans admin page
    And I select "Pro" as default plan
    Then I should see "Default plan was updated"
    And plan "Pro" should be the default

  @javascript
  Scenario: Hidden plan can be made default
    Given plan "Basic" is default
    And plan "Pro" is hidden
    When I log in as provider "foo.example.com"
    And I go to the application plans admin page
    Then I should see "Pro" in the default plans list
    And I select "Pro" as default plan
    Then I should see "Default plan was updated"
    And plan "Pro" should be the default

