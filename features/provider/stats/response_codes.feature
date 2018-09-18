@selenium @javascript
Feature: For easier debugging
  Providers need to see the status of their API
  So we provide them charts with response codes

  Background:
    Given a provider is logged in

  Scenario: Provider sees stats
    Given the provider has response codes stats data
     When on the response codes chart page
      And I select today from the stats menu
    Then there should be a c3 chart with the following data:
      | name          | total|
      | 2XX           | 10   |
      | 4XX           | 10   |
      | 5XX           | 10   |
