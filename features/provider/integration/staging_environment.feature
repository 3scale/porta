Feature: Staging Environment
  In order to integrate with 3scale
  As a provider
  I want to try it without a fuzz

  Background:
    Given a provider is logged in
    And all the rolling updates features are off
    And apicast registry is stubbed

  @javascript
  Scenario: Save staging environment with errors
    When I go to the service integration page
    And I submit a mapping rule with an empty pattern
    Then it should be clear the proxy configuration is erroneous
