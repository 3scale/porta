@javascript
Feature: Section
  In order to have multi tenant working
  as a Provider
  I want my sections to be protected

  Background:
    Given a provider "withsections.3scale.localhost"
    And provider "withsections.3scale.localhost" has section "lolsection"
    Given a provider "foo.3scale.localhost"

  Scenario: Update section
    Given I am logged in as provider "withsections.3scale.localhost" on its admin domain
    When I update "lolsection" section title to "waterfall"
    Then I should see "waterfall"
