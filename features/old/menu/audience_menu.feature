Feature: Audience menu
  In order to manage my audience
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
      And I go to the provider dashboard
      And I follow "Accounts"

  Scenario: Audience menu structure
    Then I should see menu items
    | Accounts Sub Menu         |
    | Accounts                  |
    | Portal                    |
    | Messages                  |
    | Forum                     |

  Scenario: Accounts sub menu structure
    When I follow "Accounts" within the main menu
    Then I should see menu items
    | Accounts Sub Menu         |
    | Listing                   |
    | Usage Rules               |
    | Fields Definitions        |

  Scenario: Portal sub menu structure
    When I follow "Portal" within the main menu
    Then I should see menu items
    | Accounts Sub Menu         |
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
    | Accounts Sub Menu         |
    | Inbox                     |
    | Sent messages             |
    | Trash                     |
    | Support Emails            |
    | Email Templates           |

  Scenario: Forum sub menu structure
    When I follow "Forum" within the main menu
    Then I should see menu items
    | Accounts Sub Menu         |
    | Threads                   |
    | Categories                |
    | My Threads                |
    | Preferences               |

  Scenario: Accounts sub menu structure with account plans enabled
    When provider "foo.example.com" has "account_plans" visible
    And I go to the accounts admin page
    When I follow "Accounts" within the main menu
    Then I should see menu items
      | Accounts Sub Menu        |
      | Account Plans            |

  Scenario: Accounts sub menu structure with account plans disabled
    When provider "foo.example.com" has "account_plans" denied
    And I go to the accounts admin page
    When I follow "Accounts" within the main menu
    Then I should not see menu items
      | Accounts Sub Menu        |
      | Account Plans            |

  Scenario: Accounts sub menu structure with service plans enabled
    When provider "foo.example.com" has "service_plans" visible
    And I go to the accounts admin page
    When I follow "Accounts" within the main menu
    Then I should see menu items
    | Accounts Sub Menu         |
    | Listing                   |
    | Subscriptions             |
    | Usage Rules               |
    | Fields Definitions        |

  Scenario: Portal sub menu structure with groups enabled
    When provider "foo.example.com" has "groups" switch allowed
    And I go to the provider dashboard
    And I follow "Accounts"
    When I follow "Portal" within the main menu
    Then I should see menu items
    | Accounts Sub Menu         |
    | Groups                    |
