@javascript
Feature: Sidebar for Products context

  Background:
    Given a provider
    And a product "Bananas"

  Rule: User is an admin
    Background:
      Given all the rolling updates features are on
      And an admin user "Admin" of the provider
      And the user logs in
      And they go to the overview page of product "Bananas"

    Scenario: Sidebar shows the current product
      Then they should see "Bananas" within the main menu

    Scenario: Sidebar sections
      Then the sidebar should have the following sections:
        | Product Overview |
        | Analytics        |
        | Applications     |
        | ActiveDocs       |
        | Integration      |

    Scenario: Analytics sub menu structure
      Then the sidebar should have the following items in section "Analytics":
        | Traffic            |
        | Daily Averages     |
        | Hourly Averages    |
        | Top Applications   |
        | Response Codes     |
        | Alerts             |
        | Integration Errors |

    Scenario: Applications sub menu structure
      Then the sidebar should have the following items in section "Applications":
        | Listing           |
        | Application Plans |
        | Usage Rules       |

    Scenario: Integration sub menu structure
      Then the sidebar should have the following items in section "Integration":
        | Configuration       |
        | Methods and Metrics |
        | Mapping Rules       |
        | Policies            |
        | Backends            |
        | Settings            |

    Scenario: Sidebar has section Subscriptions when service plans enabled
      Given the provider has "service_plans" switch allowed
      When they go to the overview page of product "Bananas"
      Then the sidebar should have the following sections:
        | Product Overview |
        | Analytics        |
        | Applications     |
        | Subscriptions    |
        | ActiveDocs       |
        | Integration      |
      And the sidebar should have the following items in section "Subscriptions":
        | Service Subscriptions |
        | Service Plans         |

  Rule: User is a member
    Background:
      Given a member user "Member" of the provider
      And the user has partners permission
      And the user logs in

    Scenario: Members with partners permission
      When they go to product "Bananas" applications page
      Then they should see "Bananas" within the main menu
      And the sidebar should have only the following section:
        | Applications |
      And the sidebar should have the following item in section "Applications":
        | Listing |
