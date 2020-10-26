Feature: Menu of the Account screen
  In order to browse the help pages
  As a provider
  I want to see the help dropdown

  Background:
    Given a provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"

  Scenario: Help menu dropdown
    When I go to the provider account page
    Then I should see "foo.3scale.localhost"
    And I should see the help menu items
    | Support Website        |
    | 3scale API Docs        |
    | Liquid Reference       |
