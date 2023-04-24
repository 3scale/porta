@javascript
Feature: Dashboards
  Background:
    Given a provider is logged in
    And all the rolling updates features are off

  Scenario: "Steps completed with APIcast"
    When I complete the "apicast_gateway_deployed" step
    And I go to the dashboard
    Then I should be done

  Scenario: "Last step completed and first step completed last"
    When I complete the "apicast_gateway_deployed" step
    And I complete the "api_sandbox_traffic" step
    And I go to the dashboard
    Then I should be done
