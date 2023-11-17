@javascript
Feature: Suspending tenants
  As a master
  I to want to suspend tenants so that users can't access admin portals

  Background:
    Given a provider is logged in
    And the provider is suspended

  @onpremises
  Scenario: Show Access Denied page on-premises
    When I go to the provider login page
    Then I see the support email of the provider

  Scenario: Show "Account suspended" page in SaaS
    When I go to the provider login page
    Then I should see "Please open a support case"
