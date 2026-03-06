@javascript
Feature: CMS Sections
  As a provider
  I want to manage the CMS sections

  Background:
    Given a provider is logged in
    And provider "foo.3scale.localhost" has all the templates setup

  Scenario: Show Root section
    When I go to the CMS page
    And click on "Show only 3scale content"
    And I follow "Root" within the CMS sidebar
    Then I should see "Section 'Root'"
