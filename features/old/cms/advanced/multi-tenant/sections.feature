@javascript
Feature: Section
  In order to have multi tenant working
  as a Provider
  I want my sections to be protected

  Background:
    Given a provider "withsections.3scale.localhost"
    And provider "withsections.3scale.localhost" has section "lolsection"
    Given a provider "foo.3scale.localhost"

  Scenario: Cannot index other providers sections
    Given I am logged in as provider "foo.3scale.localhost" on its admin domain
    When I go to the CMS Sections page
    Then I should not see "lolsection"

  Scenario: Can index own sections
    Given I am logged in as provider "withsections.3scale.localhost" on its admin domain
    When I go to the CMS Sections page
    Then I should see "lolsection"

  Scenario: Root section always appears
    Given I am logged in as provider "foo.3scale.localhost" on its admin domain
    When I go to the CMS Sections page
    Then I should see "Root"

  Scenario: Update section
    Given I am logged in as provider "withsections.3scale.localhost" on its admin domain
    When I update "lolsection" section title to "waterfall"
    Then I should see "waterfall"
