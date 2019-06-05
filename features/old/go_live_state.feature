@javascript
Feature: Dashboards
  Background:
    Given a provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    And all the rolling updates features are off
    And I log in as provider "foo.example.com"

  Scenario: "Steps completed with APIcast"
    When I complete the "apicast_gateway_deployed" step
    And I go to the dashboard
    Then I should be done

  Scenario: "Last step completed and first step completed last"
    When I complete the "apicast_gateway_deployed" step
    And I complete the "api_sandbox_traffic" step
    And I go to the dashboard
    Then I should be done
