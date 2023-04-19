@javascript
Feature: Audience menu
  In order to manage my audience
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider is logged in
    And go to the accounts admin page

  Scenario: Current API title
    Then I should see there is no current API

  Scenario: Audience menu structure
    Then I should see menu items
      | Accounts         |
      | Applications     |
      | Developer Portal |
      | Messages         |
      | Forum            |

  Scenario: Accounts sub menu structure
    Given menu "Accounts" is open
    Then I should see menu items
      | Listing            |
      | Usage Rules        |
      | Fields Definitions |

  Scenario: Portal sub menu structure
    Given menu "Developer Portal" is open
    Then I should see menu items
      | Content              |
      | Drafts               |
      | Redirects            |
      | Feature Visibility   |
      | Visit Portal         |
      | Liquid Reference     |
      | Signup               |
      | Service Subscription |
      | New Application      |
      | Domains & Access     |
      | Spam Protection      |
      | SSO Integrations     |

  Scenario: Messages sub menu structure
    Given menu "Messages" is open
    Then I should see menu items
      | Inbox           |
      | Sent messages   |
      | Trash           |
      | Support Emails  |
      | Email Templates |

  Scenario: Accounts sub menu structure with account plans enabled
    When the provider has "account_plans" visible
    And I go to the accounts admin page
    When menu "Accounts" is open
    Then I should see menu items
      | Account Plans |

  Scenario: Accounts sub menu structure with account plans disabled
    When the provider has "account_plans" denied
    And I go to the accounts admin page
    When I follow "Accounts" within the main menu
    Then I should not see menu items
      | Account Plans |

  Scenario: Accounts sub menu structure with service plans enabled
    When the provider has "service_plans" visible
    And I go to the accounts admin page
    When menu "Accounts" is open
    Then I should see menu items
      | Listing            |
      | Subscriptions      |
      | Usage Rules        |
      | Fields Definitions |

  Scenario: Portal sub menu structure with groups enabled
    When the provider has "groups" switch allowed
    And I go to the provider dashboard
    And I follow "0 Accounts"
    When menu "Developer Portal" is open
    Then I should see menu items
      | Groups |
