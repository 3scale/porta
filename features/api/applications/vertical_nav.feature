  Feature: Vertical nav

  Background:
    Given a provider is logged in
    And has an application

  @javascript
  Scenario: Application should not have API name header in vertical menu
    Given I'm on that application page
    Then I should see there is no current API
