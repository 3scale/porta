@javascript
Feature: Product > Applications index
  In order to control the way my buyers are using my API
  As a provider
  I want to see their applications

  Background:
    Given a provider is logged in

  Scenario: Create a new application from Account context
    And I go to the product context applications page for "API"
    Then I should see link "Create application"
