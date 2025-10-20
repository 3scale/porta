@javascript
Feature: Menu of the Account screen
  In order to edit my account details
  As a provider
  I want to see the menu

  Background:
    Given a provider is logged in

  Scenario: Current API title
    When I go to the provider account page
    Then I should see there is no current API

  Scenario: Account menu structure
    When I go to the provider account page
    Then I should see "foo.3scale.localhost"
    And I should see menu sections
      | Overview  |
      | Personal  |
      | Users     |
      | Billing   |
      | Integrate |
      | Export    |
    Then I should see menu items under "Users"
      | Listing          |
      | SSO Integrations |
    And I should see menu items under "Billing"
      | 3scale Invoices |
      | Payment Details |

  Scenario: Account menu structure with multiple users enabled
    Given the provider has "branding" switch allowed
    Given the provider has "multiple_users" switch allowed
    When I go to the provider account page
    Then I should see menu items under "Users"
      | Listing          |
      | Invitations      |
      | SSO Integrations |
    And I should see menu items under "Billing"
      | 3scale Invoices |
      | Payment Details |

  Scenario: finance disabled should not disable 3scale invoices
    Given provider "foo.3scale.localhost" has "finance" switch denied
    When I go to the provider account page
    Then I should see menu items under "Billing"
      | 3scale Invoices |
      | Payment Details |
    And I go to the 3scale invoices page
    Then I should be on the 3scale invoices page

  Scenario: Account menu when master is billing
    Given master is billing tenants
    When I go to the provider account page
    Then I should see menu items under "Billing"
      | 3scale Invoices |
      | Payment Details |

  Scenario: Account menu when master is not billing
    Given master is not billing tenants
    When I go to the provider account page
    Then I should not see "3scale Invoices"

  Scenario: Account menu structure with sso enforced
    Given the provider has "multiple_users" switch allowed
    Given provider "foo.3scale.localhost" has "enforce_sso" set to "true"
    When I go to the provider account page
    And I should see menu items under "Users"
      | Listing          |
      | SSO Integrations |

  Scenario: Personal menu structure
    When I go to the provider personal page
    And I should see menu items under "Personal"
      | Personal Details         |
      | Tokens                   |
      | Notification Preferences |

  Scenario: Navigate to export to csv
    When I go to the provider account page
    And I follow "Export"
    Then I should see the form to export data to csv
