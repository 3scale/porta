Feature: Application stats
  As an admin of provider account
  In order to know the usage of a given buyer's application
  I want to see this data in a chart

  Background:
    Given a provider has a developer "Slartibartfast" with an application name "Aircar"
    And all the rolling updates features are off

    @selenium @javascript
    Scenario: Developer's Application chart has data
      Given buyer "Slartibartfast" made 2 service transactions 12 hours ago:
        | Metric   | Value |
        | hits     |    20 |

      When the provider is logged in and visits the "Aircar" application stats
      Then there should be a c3 chart with the following data:
        | name          | total  |
        | Hits          | 40   |
