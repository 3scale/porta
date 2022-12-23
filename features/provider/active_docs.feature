# TODO: Move to features/api/services/api_docs.feature

Feature: ActiveDocs pages
  As a provider
  I want to manage my ActiveDocs

  Background:
    Given a provider is logged in
      And the provider has 1 active doc

  Scenario: Index shows the API column
    When I go to the provider active docs page
    Then the table should contain the API
