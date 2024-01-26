@javascript
Feature: Application stats
  As an admin of provider account
  In order to know the usage of a given buyer's application
  I want to see this data in a chart

  Background:
    Given a provider is logged in
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name    | State     | Default |
      | My API  | Default | Published | true    |
    And the following service plan:
      | Product | Name |
      | My API  | Gold |
    And the following account plan:
      | Issuer               | Name |
      | foo.3scale.localhost | Gold |
    And a buyer "The Buyer INC."
    And the following application:
      | Buyer          | Name     | Plan    |
      | The Buyer INC. | Test App | Default |
    # @buyer.buy!(service_plan)
    And all the rolling updates features are off

  Scenario: Developer's Application chart has data
    Given the buyer made 2 service transactions 12 hours ago:
      | Metric   | Value |
      | hits     |    20 |
    When they go to application "Test App" admin page
    And they follow "Analytics"
    Then there should be a c3 chart with the following data:
      | name          | total  |
      | Hits          | 40   |

  Scenario: Developer's Current Utilization section has data
    Given the following application plan:
      | Product | Name    |
      | My API  | Limited |
    And an usage limit on plan "Limited" for metric "hits" with period hour and value 100
    And the buyer changes to application plan "Limited"
    And the buyer makes 2 service transactions with:
      | Metric   | Value |
      | hits     |    20 |
    And the backend responds to a utilization request for application "Test App" with:
      | period   | metric_name | max_value | current_value |
      | minute   | hits        |       100 |            40 |
    When they go to application "Test App" admin page
    Then the Current Utilization panel contains the following data:
      | Metric Name | Period     | Values | %    |
      | Hits (hits) | per minute | 40/100 | 40.0 |
