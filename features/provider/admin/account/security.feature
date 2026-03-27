@javascript
Feature: Provider admin security settings
  As a provider admin
  I want to configure Permissions-Policy headers
  So that I can control browser features in the admin portal

  Background:
    Given a provider is logged in

  Scenario: View security settings page
    When I visit the provider security settings page
    Then I should see "Security"
    And I should see "Permissions-Policy Header"

  Scenario: Update admin portal Permissions-Policy header
    When I visit the provider security settings page
    And I fill in "Permissions-Policy Header" with "camera=(), microphone=(), geolocation=()"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should have Permissions-Policy header "camera=(), microphone=(), geolocation=()"

  Scenario: Clear admin portal Permissions-Policy header
    Given the provider has admin portal Permissions-Policy "camera=(), microphone=()"
    When I visit the provider security settings page
    And I fill in "Permissions-Policy Header" with ""
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should not have Permissions-Policy header

  Scenario: View default value hint
    When I visit the provider security settings page
    Then I should see "camera=(), microphone=(), geolocation=(), usb=(), payment=(), fullscreen=(self)"
