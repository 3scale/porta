@javascript
Feature: Audience menu
  In order to manage my audience
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider is logged in
    And go to the accounts admin page

  Scenario: Current API title
    Then the sidebar should not display a current API

  Scenario: Audience menu structure
    Then the sidebar should have the following sections:
      | Accounts         |
      | Applications     |
      | Developer Portal |
      | Messages         |

  Scenario: Accounts sub menu structure
    Then the sidebar should have the following items in section "Accounts":
      | Listing            |
      | Usage Rules        |
      | Fields Definitions |

  Scenario: Portal sub menu structure
    Then the sidebar should have the following items in section "Developer Portal":
      | Content              |
      | Drafts               |
      | Redirects            |
      | Feature Visibility   |
      | ActiveDocs           |
      | Visit Portal         |
      | Signup               |
      | Service Subscription |
      | New Application      |
      | Domains & Access     |
      | Bot Protection      |
      | SSO Integrations     |
      | Liquid Reference     |

  Scenario: Accounts sub menu structure with account plans enabled
    When the provider has "account_plans" visible
    And I go to the accounts admin page
    Then the sidebar should have the following items in section "Accounts":
      | Listing            |
      | Account Plans      |
      | Usage Rules        |
      | Fields Definitions |

  Scenario: Accounts sub menu structure with account plans disabled
    When the provider has "account_plans" denied
    And I go to the accounts admin page
    Then the sidebar should have the following items in section "Accounts":
      | Listing            |
      | Usage Rules        |
      | Fields Definitions |

  Scenario: Accounts sub menu structure with service plans enabled
    When the provider has "service_plans" visible
    And I go to the accounts admin page
    Then the sidebar should have the following items in section "Accounts":
      | Listing            |
      | Subscriptions      |
      | Usage Rules        |
      | Fields Definitions |

  Scenario: Portal sub menu structure with groups enabled
    When the provider has "groups" switch allowed
    And I go to the provider dashboard
    And I follow "0 Accounts"
    Then the sidebar should have the following items in section "Developer Portal":
      | Content              |
      | Drafts               |
      | Redirects            |
      | Groups               |
      | Feature Visibility   |
      | ActiveDocs           |
      | Visit Portal         |
      | Signup               |
      | Service Subscription |
      | New Application      |
      | Domains & Access     |
      | Bot Protection      |
      | SSO Integrations     |
      | Liquid Reference     |
