@javascript
Feature: Product's default application plan

  Background:
    Given a provider is logged in
    And a product "My API"
    And the following application plans:
      | Product | Name   | State     | Default |
      | My API  | Free   | Published | true    |
      | My API  | Pro    | Published |         |
      | My API  | Secret | Hidden    |         |
    And they go to the product's application plans admin page

  Scenario: Set a default application plan
    When they select "Pro" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "Pro" is the option selected in "Default plan"

  Scenario: Unset the default application plan
    Given "Free" is the option selected in "Default plan"
    When they select "No plan selected" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "No plan selected" is the option selected in "Default plan"

  Scenario: Set a hidden application plan as default
    When they select "Secret" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "Secret" is the option selected in "Default plan"

  Scenario: Set an application plan that does not exist
    Given application plan "Pro" has been deleted
    When they select "Pro" from "Default plan"
    And press "Change plan"
    Then they should see "Not found"
