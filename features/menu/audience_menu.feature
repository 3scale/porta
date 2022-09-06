Feature: Audience menu
  In order to manage my audience
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider is logged in

  @javascript
  Scenario: Application overview
    Given has an application
    When I'm on that application page
    Then I should see there is no current API
