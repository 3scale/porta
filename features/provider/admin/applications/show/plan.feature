@javascript
Feature: Application plan details card

  Background:
    Given a provider
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the buyer has an application "My App" for the product
    And the provider logs in

  Scenario: Current Plan can always be customized
    When they go to the application's admin page
    Then they should see "Convert to a Custom Plan"

  Scenario: Customize the plan
    Given the application uses plan "Free"
    And they go to the application's admin page
    And they should see "Application Plan: Free"
    When they follow "Convert to a Custom Plan"
    Then they should see "Custom Application Plan"
    But should not see "Application Plan: Free"

  Scenario: Remove customization of the plan
    Given the application uses a custom plan
    And they go to the application's admin page
    And they should see "Custom Application Plan"
    When they press "Remove customization"
    Then should not see "Custom Application Plan"
