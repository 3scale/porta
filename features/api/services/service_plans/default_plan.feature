@javascript
Feature: Product's default service plan

  Background:
    Given a provider is logged in
    And the provider has "service_plans" allowed
    And a product "My API"
    And the following service plan:
      | Product | Name   | State     | Default |
      | My API  | Free   | Published | true    |
      | My API  | Pro    | Published | false   |
      | My API  | Secret | Hidden    | false   |
    And they go to product "My API" service plans admin page

  Scenario: Set a service plan as default
    When they select "Pro" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "Pro" is the option selected in "Default plan"

  Scenario: Unset the default service plan
    Given "Free" is the option selected in "Default plan"
    When they select "No plan selected" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "No plan selected" is the option selected in "Default plan"

  Scenario: Set a hidden service plan as default
    When they select "Secret" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "Secret" is the option selected in "Default plan"

  Scenario: Set a service plan that does not exist
    Given service plan "Pro" has been deleted
    When they select "Pro" from "Default plan"
    And press "Change plan"
    Then they should see "Not found"
