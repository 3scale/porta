@javascript
Feature: Provider's default account plan

  Background:
    Given a provider is logged in
    And the provider has "account_plans" allowed
    And the following account plan:
      | Issuer               | Name   | State     | Default |
      | foo.3scale.localhost | Free   | Published | true    |
      | foo.3scale.localhost | Pro    | Published |         |
      | foo.3scale.localhost | Secret | Hidden    |         |
    And they go to the account plans admin page

  Scenario: Set a default account plan
    When they select "Pro" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "Pro" is the option selected in "Default plan"

  Scenario: Unset the default account plan
    Given "Free" is the option selected in "Default plan"
    When they select "No plan selected" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "No plan selected" is the option selected in "Default plan"

  Scenario: Set a hidden account plan as default
    When they select "Secret" from "Default plan"
    And press "Change plan"
    Then they should see "The default plan has been changed"
    And "Secret" is the option selected in "Default plan"

  Scenario: Set an account plan that does not exist
    Given account plan "Pro" has been deleted
    When they select "Pro" from "Default plan"
    And press "Change plan"
    Then they should see "Not found"
