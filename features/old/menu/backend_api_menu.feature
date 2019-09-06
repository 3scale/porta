Feature: Backend API menu
  In order to manage my Backend API
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider "foo.example.com" with backend api
      And current domain is the admin domain of provider "foo.example.com"
      And all the rolling updates features are on
      And I log in as provider "foo.example.com"
      And I go to the provider dashboard
      # TODO: Replace this step with actual navigation from the Dashboard once Backend APIs are listed there
      And I go to the backend api overview

  Scenario: API menu structure
    Then I should see menu items
    | Overview                  |
    | Methods & Metrics         |
    | Mapping Rules             |
