@javascript
Feature: Applications index
  In order to control the way my buyers are using my API
  As a provider
  I want to see their applications

  Background:
    Given a provider is logged in
    And the provider has one buyer

  Scenario: Create a new application from Account context
    And I go to the account context applications page for "bob"
    Then I should see link "Create application"

  Scenario: Create a new application from Audience context
    And I go to the applications admin page
    Then I should see link "Create application"

  Scenario: Create a new application from Product context
    And I go to the product context applications page for "API"
    Then I should see link "Create application"
