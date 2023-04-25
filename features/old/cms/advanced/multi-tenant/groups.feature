@javascript
Feature: Groups
  In order to have multi tenant working
  as a Provider
  I want to manage ONLY MY groups

  Background:
    Given a provider "withgroups.3scale.localhost"
    And provider "withgroups.3scale.localhost" has groups for buyers:
      | name        |
      | BuyerGroup1 |
    And provider "withgroups.3scale.localhost" has multiple applications enabled
    And provider "withgroups.3scale.localhost" has "groups" switch allowed
    Given a provider "nogroups.3scale.localhost"
    And provider "nogroups.3scale.localhost" has multiple applications enabled
    And an approved buyer "userfornogroups.3scale.localhost" signed up to provider "nogroups.3scale.localhost"
    And provider "nogroups.3scale.localhost" has "groups" switch allowed

  Scenario: Cannot index other providers groups
    When current domain is the admin domain of provider "nogroups.3scale.localhost"
    And I am logged in as provider "nogroups.3scale.localhost"
    When I go to the groups page
    Then I should see no groups

  Scenario: Can index own groups
    When current domain is the admin domain of provider "withgroups.3scale.localhost"
    And I am logged in as provider "withgroups.3scale.localhost"
    When I go to the groups page
    Then I should see my groups
