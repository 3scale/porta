@javascript
Feature: CMS Sections
  As a provider
  I want to manage the CMS sections

  Background:
    Given a provider is logged in
    And provider "foo.3scale.localhost" has all the templates setup

  Scenario: Show Root section
    When I go to the CMS page
    And I switch to 3scale content in the CMS sidebar
    And I follow "Root" in the CMS sidebar
    Then I should see "Section 'Root'"
