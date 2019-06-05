@javascript
Feature: Groups
  In order to have multi tenant working
  as a Provider
  I want to manage ONLY MY groups

  Background:
    Given a provider "withgroups.example.com"
      And provider "withgroups.example.com" has groups for buyers:
      | name        |
      | BuyerGroup1 |
      And provider "withgroups.example.com" has multiple applications enabled
      And provider "withgroups.example.com" has "groups" switch allowed

    Given a provider "nogroups.example.com"
      And provider "nogroups.example.com" has multiple applications enabled
      And an approved buyer "userfornogroups.example.com" signed up to provider "nogroups.example.com"
      And provider "nogroups.example.com" has "groups" switch allowed

  Scenario: Cannot index other providers groups
     When current domain is the admin domain of provider "nogroups.example.com"
      And I am logged in as provider "nogroups.example.com"
     When I go to the groups page
     Then I should see no groups

  Scenario: Can index own groups
     When current domain is the admin domain of provider "withgroups.example.com"
     And I am logged in as provider "withgroups.example.com"
    When I go to the groups page
    Then I should see my groups
