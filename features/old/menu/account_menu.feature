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
    | Payment Details       |
    | Users                     |

  Scenario: Account menu structure
    Given the provider has "branding" switch allowed
    When I go to the provider account page
    Then I should see menu items
    | Overview                  |
    | Export                    |
    | Logo                      |
    | 3scale Invoices           |
    | Payment Details       |
    | Users                     |

  Scenario: Account menu structure with multiple users enabled
    Given the provider has "branding" switch allowed
    Given the provider has "multiple_users" switch allowed
    When I go to the provider account page
    Then I should see menu items
    | Overview                  |
    | Export                    |
    | Logo                      |
    | 3scale Invoices           |
    | Payment Details       |
    | Users                     |
    | Invitations               |
    | SSO Integrations          |

  Scenario: Account menu structure with sso enforced
    Given the provider has "branding" switch allowed
    Given the provider has "multiple_users" switch allowed
    Given provider "foo.example.com" has "enforce_sso" set to "true"
    When I go to the provider account page
    Then I should not see link "Invitations"

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
