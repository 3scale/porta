Feature: Audience menu
  In order to manage my audience
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
      And I go to the provider dashboard
      And I follow "0 Accounts"

  Scenario: Audience menu structure
    Then I should see menu items
    | Accounts                  |
    | Portal                    |
    | Messages                  |
    | Forum                     |

  Scenario: Accounts sub menu structure
    When I follow "Accounts" within the main menu
    Then I should see menu items
    | Listing                   |
    | Usage Rules               |
    | Fields Definitions        |

  Scenario: Portal sub menu structure
    When I follow "Developer Portal" within the main menu
    Then I should see menu items
    | Content                   |
    | Drafts                    |
    | Redirects                 |
    | Feature Visibility        |
    | Visit Portal              |
    | Liquid Reference          |
    | Signup                    |
    | Service Subscription      |
    | New Application           |
    | Domains & Access          |
    | Spam Protection           |
    | SSO Integrations          |

  Scenario: Messages sub menu structure
    When I follow "Messages" within the main menu
    Then I should see menu items
    | Inbox                     |
    | Sent messages             |
    | Trash                     |
    | Support Emails            |
    | Email Templates           |

  Scenario: Forum sub menu structure
    When I follow "Forum" within the main menu
    Then I should see menu items
    | Threads                   |
    | Categories                |
    | My Threads                |
    | Preferences               |

  Scenario: Accounts sub menu structure with account plans enabled
    When provider "foo.example.com" has "account_plans" visible
    And I go to the accounts admin page
    When I follow "Accounts" within the main menu
    Then I should see menu items
      | Account Plans            |

  Scenario: Accounts sub menu structure with account plans disabled
    When provider "foo.example.com" has "account_plans" denied
    And I go to the accounts admin page
    When I follow "Accounts" within the main menu
    Then I should not see menu items
      | Account Plans            |

  Scenario: Accounts sub menu structure with service plans enabled
    When provider "foo.example.com" has "service_plans" visible
    And I go to the accounts admin page
    When I follow "Accounts" within the main menu
    Then I should see menu items
    | Listing                   |
    | Subscriptions             |
    | Usage Rules               |
    | Fields Definitions        |

  Scenario: Portal sub menu structure with groups enabled
    When provider "foo.example.com" has "groups" switch allowed
    And I go to the provider dashboard
    And I follow "0 Accounts"
    When I follow "Developer Portal" within the main menu
    Then I should see menu items
    | Groups                    |
