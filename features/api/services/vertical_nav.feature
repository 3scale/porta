  Feature: Vertical nav

  Background:
    Given a provider is logged in
    And I go to the product context applications page for "API"

  @javascript
  Scenario: Product should have API name header in vertical menu
    Then I should see there is current API
