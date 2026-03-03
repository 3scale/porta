@javascript
Feature: Menu of the Account screen
  In order to edit my account details
  As a provider
  I want to see the menu

  Background:
    Given a provider is logged in

  Scenario: Current API title
    When I go to the provider account page
    Then the sidebar should not display a current API

  Scenario: Account menu structure
    When I go to the provider account page
    Then I should see "foo.3scale.localhost"
    And the sidebar should have the following sections:
      | Overview  |
      | Personal  |
      | Users     |
      | Billing   |
      | Integrate |
      | Export    |
    Then the sidebar should have the following items in section "Users":
      | Listing          |
      | SSO Integrations |
    And the sidebar should have the following items in section "Billing":
      | 3scale Invoices |
      | Payment Details |

  Scenario: Account menu structure with multiple users enabled
    Given the provider has "branding" switch allowed
    Given the provider has "multiple_users" switch allowed
    When I go to the provider account page
    Then the sidebar should have the following items in section "Users":
      | Listing          |
      | Invitations      |
      | SSO Integrations |
    And the sidebar should have the following items in section "Billing":
      | 3scale Invoices |
      | Payment Details |

  Scenario: finance disabled should not disable 3scale invoices
    Given provider "foo.3scale.localhost" has "finance" switch denied
    When I go to the provider account page
    Then the sidebar should have the following items in section "Billing":
      | 3scale Invoices |
      | Payment Details |
    And I go to the 3scale invoices page
    Then I should be on the 3scale invoices page

  Scenario: Account menu when master is billing
    Given master is billing tenants
    When I go to the provider account page
    Then the sidebar should have the following items in section "Billing":
      | 3scale Invoices |
      | Payment Details |

  Scenario: Account menu when master is not billing
    Given master is not billing tenants
    When I go to the provider account page
    Then I should not see "3scale Invoices"

  Scenario: Account menu structure with sso enforced
    Given the provider has "multiple_users" switch allowed
    And the provider has the following setting:
      | enforce sso | true |
    When I go to the provider account page
    And the sidebar should have the following items in section "Users":
      | Listing          |
      | SSO Integrations |

  Scenario: Personal menu structure
    When I go to the provider personal page
    And the sidebar should have the following items in section "Personal":
      | Personal Details         |
      | Tokens                   |
      | Notification Preferences |

  Scenario: Navigate to export to csv
    When I go to the provider account page
    And I follow "Export"
    Then I should see the form to export data to csv
