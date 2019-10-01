Feature: API menu
  In order to manage my API
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And all the rolling updates features are on
      And I log in as provider "foo.example.com"
      And I go to the provider dashboard
      And I follow "Overview"

  Scenario: API menu structure
    Then I should see menu items
    | Overview                  |
    | Analytics                 |
    | Applications              |
    | ActiveDocs                |
    | Integration               |

  Scenario: Analytics sub menu structure
    When I follow "Analytics" within the main menu
    Then I should see menu items
    | Usage                     |
    | Daily Averages            |
    | Hourly Averages           |
    | Top Applications          |
    | Response Codes            |
    | Alerts                    |
    | Integration Errors        |

  Scenario: Applications sub menu structure
    When I follow "Applications" within the main menu
    Then I should see menu items
    | Listing                   |
    | Application Plans         |

  Scenario: Integration sub menu structure provider has api as product enabled
    Given the account has api_as_product rolling update enabled
    And I have api_as_product feature disabled
    When I follow "Overview"
    When I follow "Integration" within the main menu
    Then I should see menu items
    | Configuration             |
    | Methods & Metrics         |
    | Mapping Rules             |
    | Settings                  |

  Scenario: Integration sub menu structure when provider does not have api as product enabled
    Given I have api_as_product feature disabled
    When I follow "Overview"
    And I follow "Integration" within the main menu
    Then I should see menu items
    | Configuration             |
    | Methods & Metrics         |
    | Settings                  |

  Scenario: Integration sub menu structure for API as Product
    Given I have api_as_product feature enabled
    When I follow "Overview"
    And I follow "Integration" within the main menu
    Then I should see menu items
    | Configuration             |
    | Methods & Metrics         |
    | Mapping Rules             |
    | Policies                  |
    | Backends                  |
    | Settings                  |

  Scenario: API menu structure with service plans enabled
    When provider "foo.example.com" has "service_plans" switch allowed
    When I go to the API dashboard page
    Then I should see menu items
    | Overview                  |
    | Analytics                 |
    | Applications              |
    | Subscriptions             |
    | ActiveDocs                |
    | Integration               |

  Scenario: Subscriptions sub menu structure
    When provider "foo.example.com" has "service_plans" switch allowed
    When I go to the API dashboard page
    When I follow "Subscriptions" within the main menu
    Then I should see menu items
    | Service Subscriptions     |
    | Service Plans             |

  Scenario: API menu structure with end user plans enabled
    When provider "foo.example.com" has "end_users" switch allowed
    When I go to the API dashboard page
    Then I should see menu items
    | Overview                  |
    | Analytics                 |
    | Applications              |
    | End-users                 |
    | ActiveDocs                |
    | Integration               |

  Scenario: End-users sub menu structure
    When provider "foo.example.com" has "end_users" switch allowed
    When I go to the API dashboard page
    When I follow "End-users" within the main menu
    Then I should see menu items
    | Search                    |
    | End-user Plans            |
