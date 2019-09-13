@javascript
Feature: CMS Sections
  As a provider
  I want to manage the CMS sections

  Background:
  Given a provider "foo.example.com"
    And provider "foo.example.com" has all the templates setup
    And I am logged in as provider "foo.example.com" on its admin domain

  Scenario: Show Root section
   When I go to the CMS page
    And I switch to 3scale content in the CMS sidebar
    And I follow "Root" in the CMS sidebar
   Then I should see "Section 'Root'"
