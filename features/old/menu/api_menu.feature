@javascript
Feature: API menu
  In order to manage my API
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And all the rolling updates features are on
      And I log in as provider "foo.3scale.localhost"
      And I go to the provider dashboard
      And I follow "API"

  Scenario: Current API title
    Then I should see the current API is "API"

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
    | Traffic                   |
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

  Scenario: Integration sub menu structure
    When I follow "Overview"
    And I follow "Integration" within the main menu
    Then I should see menu items
    | Configuration             |
    | Methods and Metrics         |
    | Mapping Rules             |
    | Policies                  |
    | Backends                  |
    | Settings                  |

  Scenario: API menu structure with service plans enabled
    When provider "foo.3scale.localhost" has "service_plans" switch allowed
    When I go to the API dashboard page
    Then I should see menu items
    | Overview                  |
    | Analytics                 |
    | Applications              |
    | Subscriptions             |
    | ActiveDocs                |
    | Integration               |

  Scenario: Subscriptions sub menu structure
    When provider "foo.3scale.localhost" has "service_plans" switch allowed
    When I go to the API dashboard page
    When I follow "Subscriptions" within the main menu
    Then I should see menu items
    | Service Subscriptions     |
    | Service Plans             |
