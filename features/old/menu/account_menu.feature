@javascript
Feature: Menu of the Account screen
  In order to edit my account details
  As a provider
  I want to see the menu

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

  Scenario: Account menu structure
    When I go to the provider account page
    Then I should see "foo.example.com"
    And I should see menu items
    | Overview                  |
    | Export                    |
    | 3scale Invoices           |
    | Payment Details           |
    | Users                     |

  Scenario: Account menu structure with multiple users enabled
    Given the provider has "branding" switch allowed
    Given the provider has "multiple_users" switch allowed
    When I go to the provider account page
    Then I should see menu items
    | Overview                  |
    | Export                    |
    | 3scale Invoices           |
    | Payment Details           |
    | Users                     |
    | SSO Integrations          |

  Scenario: finance disabled should not disable 3scale invoices
    Given provider "foo.example.com" has "finance" switch denied
    When I go to the provider dashboard
     And I follow "Account"
     And I follow "Billing"
     And I follow "3scale Invoices"
    Then I should be on my invoices from 3scale page

  Scenario: Account menu when master is billing
    Given master is billing tenants
    When I go to the provider dashboard
     And I follow "Account"
     And I follow "Billing"
    Then I should see "3scale Invoices"

  Scenario: Account menu when master is not billing
    Given master is not billing tenants
    When I go to the provider dashboard
     And I follow "Account"
    Then I should not see "3scale Invoices"

  Scenario: Account menu structure with sso enforced
    Given the provider has "multiple_users" switch allowed
    Given provider "foo.example.com" has "enforce_sso" set to "true"
    When I go to the provider account page
    Then I should not see "Invitations"

  Scenario: Personal menu structure
    When I go to the provider personal page
    Then I should see "foo.example.com"
    And I should see menu items
    | Personal Details          |
    | Tokens                    |
    | Notification Preferences  |

  Scenario: Navigate to export to csv
    When I go to the provider account page
    And I follow "Export"
    Then I should see the form to export data to csv
