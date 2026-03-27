@javascript
Feature: Developer portal security settings
  As a provider admin
  I want to configure Permissions-Policy headers for the developer portal
  So that I can control browser features available to my developers

  Background:
    Given a provider is logged in

  Scenario: View developer portal security settings page
    When I visit the developer portal security settings page
    Then I should see "Security"
    And I should see "Permissions-Policy Header"

  Scenario: Update developer portal Permissions-Policy header
    When I visit the developer portal security settings page
    And I fill in "Permissions-Policy Header" with "camera=(), fullscreen=(self)"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should have Permissions-Policy header "camera=(), fullscreen=(self)"

  Scenario: Clear developer portal Permissions-Policy header (permissive)
    Given the provider has developer portal Permissions-Policy "camera=()"
    When I visit the developer portal security settings page
    And I fill in "Permissions-Policy Header" with ""
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should not have Permissions-Policy header

  Scenario: View permissive default hint
    When I visit the developer portal security settings page
    Then I should see "Leave empty for permissive policy"
