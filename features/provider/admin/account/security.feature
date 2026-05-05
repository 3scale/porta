@javascript
Feature: Provider admin security settings
  As a provider admin
  I want to configure security headers in my admin portal

  Background:
    Given a provider is logged in

  Scenario: View security settings page
    When I go to the provider security settings page
    Then I should see "Security"
    And I should see "Permissions-Policy Header"
    And I should see "Content-Security-Policy Header"
    And I should see "Content-Security-Policy-Report-Only Header"

  Scenario: Update admin portal Permissions-Policy header
    When I go to the provider security settings page
    And I check "override_permissions_policy_header_admin"
    And I fill in "Permissions-Policy Header" with "camera=(), microphone=(), geolocation=()"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should have configured Permissions-Policy header "camera=(), microphone=(), geolocation=()"

  Scenario: Clear admin portal Permissions-Policy header
    Given the provider has configured admin portal Permissions-Policy "camera=(), microphone=()"
    When I go to the provider security settings page
    And I fill in "Permissions-Policy Header" with ""
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should not have configured Permissions-Policy header

  Scenario: Uncheck override deletes existing Permissions-Policy setting
    Given the provider has configured admin portal Permissions-Policy "camera=(), microphone=()"
    When I go to the provider security settings page
    And I uncheck "override_permissions_policy_header_admin"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should not have configured Permissions-Policy header

  Scenario: View default value hint
    When I go to the provider security settings page
    Then I should see "camera=(), microphone=(), geolocation=(), payment=(), usb=(), fullscreen=(self)"

  Scenario: Update admin portal Content-Security-Policy header
    When I go to the provider security settings page
    And I check "override_csp_header_admin"
    And I fill in "csp_header_admin" with "default-src 'self'"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should have configured CSP header "default-src 'self'"

  Scenario: Uncheck override deletes existing Content-Security-Policy setting
    Given the provider has configured admin portal CSP "default-src 'self'"
    When I go to the provider security settings page
    And I uncheck "override_csp_header_admin"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should not have configured CSP header

  Scenario: Update admin portal Content-Security-Policy-Report-Only header
    When I go to the provider security settings page
    And I check "override_csp_report_only_header_admin"
    And I fill in "csp_report_only_header_admin" with "default-src 'self'"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should have configured CSP Report-Only header "default-src 'self'"

  Scenario: Uncheck override deletes existing Content-Security-Policy-Report-Only setting
    Given the provider has configured admin portal CSP Report-Only "default-src 'self'"
    When I go to the provider security settings page
    And I uncheck "override_csp_report_only_header_admin"
    And I press "Update Security Settings"
    Then I should see "Security settings updated"
    And the admin portal should not have configured CSP Report-Only header
