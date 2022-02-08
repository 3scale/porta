Feature: Backend menu
  In order to manage my Backend
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And all the rolling updates features are on
      And I log in as provider "foo.3scale.localhost"
      And I go to the provider dashboard
      # TODO: Replace this step with actual navigation from the Dashboard once Backend APIs are listed there
      And I go to the backend api overview

  @javascript
  Scenario: Current API title
    Then I should see the current API is "API"

  Scenario: API menu structure
    Then I should see menu items
    | Overview                    |
    | Methods and Metrics         |
    | Mapping Rules               |
