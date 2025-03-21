@javascript
Feature: API menu
  In order to manage my API
  As a provider
  I want to see a menu that lets me do that

  Rule: User is an admin
    Background:
      Given a provider is logged in
      And all the rolling updates features are on
      And I go to the provider dashboard
      And I follow "API"

    Scenario: Current API title
      Then the name of the product can be seen on top of the menu

    Scenario: API menu structure
      Then I should see menu sections
        | Product Overview     |
        | Analytics    |
        | Applications |
        | ActiveDocs   |
        | Integration  |

    Scenario: Analytics sub menu structure
      Then I should see menu items under "Analytics"
        | Traffic            |
        | Daily Averages     |
        | Hourly Averages    |
        | Top Applications   |
        | Response Codes     |
        | Alerts             |
        | Integration Errors |

    Scenario: Applications sub menu structure
      Then I should see menu items under "Applications"
        | Listing           |
        | Application Plans |
        | Usage Rules       |

    Scenario: Integration sub menu structure
      When I follow "Product Overview"
      Then I should see menu items under "Integration"
        | Configuration       |
        | Methods and Metrics |
        | Mapping Rules       |
        | Policies            |
        | Backends            |
        | Settings            |

    Scenario: API menu structure with service plans enabled
      When provider "foo.3scale.localhost" has "service_plans" switch allowed
      When I go to the API dashboard page
      Then I should see menu sections
        | Product Overview      |
        | Analytics     |
        | Applications  |
        | Subscriptions |
        | ActiveDocs    |
        | Integration   |

    Scenario: Subscriptions sub menu structure
      When provider "foo.3scale.localhost" has "service_plans" switch allowed
      When I go to the API dashboard page
      Then I should see menu items under "Subscriptions"
        | Service Subscriptions |
        | Service Plans         |

  Rule: User is a member
    Background:
      Given a provider
      And a member user "Member" of the provider
      And the user logs in

    Scenario: Members with partners permission
      Given the user has partners permission
      When they go to product "API" applications page
      Then the name of the product can be seen on top of the menu
      And they should see menu sections
        | Applications  |
      And they should see menu items under "Applications"
        | Listing |
