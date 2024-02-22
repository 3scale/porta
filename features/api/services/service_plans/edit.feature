@javascript
Feature: Service subscription approval required

  Background:
    Given a provider is logged in
    And the provider has "service_plans" allowed
    And a product "My API"
    And the following service plan:
      | Product | Name |
      | My API  | Free |

  Scenario: Make new accounts require approval from admin
    Given they go to service plan "Free" admin edit page
    When the form is submitted with:
      | Service subscriptions require approval? | Yes        |
    Then new service subscriptions with service plan "Free" will be pending for approval
