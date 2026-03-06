@javascript
Feature: Section
  In order to have multi tenant working
  as a Provider
  I want my sections to be protected

  Background:
    Given a provider "withsections.3scale.localhost"
    And the provider has the following section:
      | Title      |
      | lolsection |
    Given a provider "foo.3scale.localhost"

  Scenario: Update section
    Given I am logged in as provider "withsections.3scale.localhost" on its admin domain
    And they go to the CMS edit page of section "lolsection"
    And the form is submitted with:
      | Title | waterfall |
    Then I should see "waterfall"
    And a success toast alert is displayed with text "Section saved successfully"
