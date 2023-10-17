Feature: Application stats
  As an admin of provider account
  In order to know the usage of a given buyer's application
  I want to see this data in a chart

  Background:
    Given a provider is logged in
    And the provider has a buyer with an application
    And all the rolling updates features are off

  @javascript
  Scenario: Developer's Application chart has data
    Given the buyer made 2 service transactions 12 hours ago:
      | Metric   | Value |
      | hits     |    20 |
    When they go to the provider application page
    And they follow "Analytics"
    Then there should be a c3 chart with the following data:
      | name          | total  |
      | Hits          | 40   |

  @javascript
  Scenario: Developer's Current Utilization section has data
    Given the provider has a free application plan "Limited"
    And an usage limit on plan "Limited" for metric "hits" with period hour and value 100
    And the buyer changed to application plan "Limited"
    And the buyer makes 2 service transactions with:
      | Metric   | Value |
      | hits     |    20 |
    And the backend responds to a utilization request for the application with:
      | period   | metric_name | max_value | current_value |
      | minute   | hits        |       100 |            40 |
    When they go to the provider application page
    Then the Current Utilization panel contains the following data:
      | Metric Name | Period     | Values | %    |
      | Hits (hits) | per minute | 40/100 | 40.0 |
