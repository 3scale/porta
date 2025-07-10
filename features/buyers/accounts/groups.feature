@javascript
Feature: Buyer account group memberships

  As a provider admin I want to add and remove buyer accounts from CMS groups.

  Background:
    Given a provider is logged in
    And the provider has "groups" switch allowed
    And a buyer "Bob buyer"

  Scenario: Navigation
    When they select "Audience" from the context selector
    And they follow "Bob buyer"
    And they follow "0 Group Memberships"
    Then the current page is the buyer account "Bob buyer" groups page

  Rule: Provider has no groups
    Background:
      Given the provider has no CMS groups

    Scenario: Empty state
      When they go to the buyer account "Bob buyer" groups page
      Then they should see an empty state

  Rule: Provider has some groups
    Background:
      And the provider has the following CMS groups:
        | Name  |
        | Alpha |
        | Beta  |
        | Gamma |

    Scenario: Update group memberships
      When they go to the buyer account "Bob buyer" groups page
      And the form is submitted with:
        | Alpha | Yes |
        | Beta  | No  |
        | Gamma | No  |
      Then a toast alert is displayed with text "Account updated"
      And the "Alpha" checkbox should be checked

    Scenario: Remove all group memberships
      When they go to the buyer account "Bob buyer" groups page
      And the form is submitted with:
        | Alpha | No |
        | Beta  | No |
        | Gamma | No |
      Then a toast alert is displayed with text "Account updated"
      And all groups should be unchecked

  Rule: Multitenant
    Background:
      Given another provider "nfp.3scale.localhost"
      And an approved buyer "Lesley" signed up to the provider
      And the provider has "groups" switch allowed
      And the provider has the following CMS groups:
        | Name    |
        | Group A |
        | Group B |

    Scenario: Provider cannot see other providers' groups
      Given current domain is the admin domain of provider "nfp.3scale.localhost"
      And I am logged in as provider "nfp.3scale.localhost"
      When they go to the buyer account "Bob buyer" groups page
      Then they should see "Not found"
      When they go to the buyer account "Lesley" groups page
      Then they should see "Group A"
      But they should not see "Alpha"
