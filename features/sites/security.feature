@javascript
Feature: Developer portal security settings
  As a provider admin
  I want to configure security headers for my developer portal

  Background:
    Given a provider is logged in

  Scenario: View developer portal security settings page
    When I go to the developer portal security settings page
    Then I should see "Security"
    And I should see "Permissions-Policy Header"
    And I should see "Content-Security-Policy Header"
    And I should see "Content-Security-Policy-Report-Only Header"

  Scenario: Update developer portal Permissions-Policy header
    When I go to the developer portal security settings page
    And I check "override_permissions_policy_header_developer"
    And I fill in "Permissions-Policy Header" with "camera=(), fullscreen=(self)"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should have configured Permissions-Policy header "camera=(), fullscreen=(self)"

  Scenario: Clear developer portal Permissions-Policy header (permissive)
    Given the provider has configured developer portal Permissions-Policy "camera=()"
    When I go to the developer portal security settings page
    And I fill in "Permissions-Policy Header" with ""
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should not have configured Permissions-Policy header

  Scenario: Uncheck override deletes existing Permissions-Policy setting
    Given the provider has configured developer portal Permissions-Policy "camera=()"
    When I go to the developer portal security settings page
    And I uncheck "override_permissions_policy_header_developer"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should not have configured Permissions-Policy header

  Scenario: View permissive default hint
    When I go to the developer portal security settings page
    Then I should see "Default: none"

  Scenario: Update developer portal Content-Security-Policy header
    When I go to the developer portal security settings page
    And I check "override_csp_header_developer"
    And I fill in "csp_header_developer" with "default-src 'self'"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should have configured CSP header "default-src 'self'"

  Scenario: Uncheck override deletes existing Content-Security-Policy setting
    Given the provider has configured developer portal CSP "default-src 'self'"
    When I go to the developer portal security settings page
    And I uncheck "override_csp_header_developer"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should not have configured CSP header

  Scenario: Update developer portal Content-Security-Policy-Report-Only header
    When I go to the developer portal security settings page
    And I check "override_csp_report_only_header_developer"
    And I fill in "csp_report_only_header_developer" with "default-src 'self'"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should have configured CSP Report-Only header "default-src 'self'"

  Scenario: Uncheck override deletes existing Content-Security-Policy-Report-Only setting
    Given the provider has configured developer portal CSP Report-Only "default-src 'self'"
    When I go to the developer portal security settings page
    And I uncheck "override_csp_report_only_header_developer"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the developer portal should not have configured CSP Report-Only header
