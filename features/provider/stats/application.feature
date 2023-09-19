Feature: Application stats
  As an admin of provider account
  In order to know the usage of a given buyer's application
  I want to see this data in a chart

  Background:
    Given a provider has a developer "Slartibartfast" with an application name "Aircar"
    And all the rolling updates features are off

    @javascript
    Scenario: Developer's Application chart has data
      Given buyer "Slartibartfast" made 2 service transactions 12 hours ago:
        | Metric   | Value |
        | hits     |    20 |

      When the provider is logged in and visits the "Aircar" application stats
      Then there should be a c3 chart with the following data:
        | name          | total  |
        | Hits          | 40   |

  @javascript
  Scenario: Developer's Current Utilization section has data
    Given the provider has a free application plan "Limited"
    And an usage limit on plan "Limited" for metric "hits" with period hour and value 100
    And buyer "Slartibartfast" changed to plan "Limited"
    And buyer "Slartibartfast" makes 2 service transactions with:
      | Metric   | Value |
      | hits     |    20 |
    And the backend will respond to a utilization request for application "Aircar" with:
      """
      { "status": "found",
        "utilization": [{
            "period": "minute",
            "metric_name": "hits",
            "max_value": 100,
            "current_value": 40
        }]
      }
      """
    When the provider is logged in and visits the "Aircar" application page
    Then the Current Utilization panel should contain the following data:
      | Metric Name | Period     | Values | %    |
      | Hits (hits) | per minute | 40/100 | 40.0 |
