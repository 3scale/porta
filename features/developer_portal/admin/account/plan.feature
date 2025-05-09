Feature: Dev Portal Buyer Account Plan
  As a buyer
  I want to manage the plan I've signed up to

  Background:
    Given a provider
    And the provider has "account_plans" visible
    And a buyer "Jane"
    And the buyer logs in

  Scenario: Plans tab is hidden with a single account plan
    When they go to settings
    Then there shouldn't be a link to "Plans"

  Scenario: Plans tab is hidden with multiple account plans but not published
    Given the following account plans:
      | Issuer               | Name       | State  |
      | foo.3scale.localhost | Player     | Hidden |
      | foo.3scale.localhost | GameMaster | Hidden |
    When they go to settings
    Then there shouldn't be a link to "Plans"

  Rule: Multiple published account plans

    Background:
      Given the following account plans:
        | Issuer               | Name       | State     |
        | foo.3scale.localhost | Player     | Published |
        | foo.3scale.localhost | GameMaster | Published |

    Scenario: Plans tab is available with multiple account plans
      Given the buyer changes to account plan "Player"
      When they go to settings
      And follow "Plans"
      Then they should see "You are currently on plan Player"
      And they should see "View plan"

    Scenario: No plan change when the functionality is disabled
      Given the provider does not allow to change account plan
      When they go to the account plans page
      Then they should not see "View plan"
      And they should see "Your Plan"

    @javascript
    Scenario: Plans tab is hidden when provider do not allow account plans
      Given the provider has "account_plans" hidden
      When they go to settings
      Then there shouldn't be a link to "Plans"

    @javascript
    Scenario: Changing the account plan directly
      Given the provider allows to change account plan directly
      When they go to the account plans page
      And they select "GameMaster" from "View plan"
      And they press "Change Plan"
      And confirm the dialog
      Then they should see the flash message "Plan was successfully changed to GameMaster"

    @javascript
    Scenario: Requesting an account plan change
      Given the provider allows to change account plan by request
      When they go to the account plans page
      And they select "GameMaster" from "View plan"
      And they press invisible "Request Plan Change"
      And confirm the dialog
      Then they should see the flash message "The plan change has been requested"

    @javascript
    Scenario: Plan change is requested without a credit card
      Given the provider allows to change account plan only with credit card
      When they go to the account plans page
      And they select "GameMaster" from "View plan"
      And they press "Request Plan Change"
      And confirm the dialog
      Then they should see the flash message "The plan change has been requested"

    @javascript
    Scenario: Plan can be changed directly with a credit card
      Given the provider allows to change account plan only with credit card
      And the buyer has a valid credit card
      When they go to the account plans page
      And they select "GameMaster" from "View plan"
      And they press "Change Plan"
      And confirm the dialog
      Then they should see the flash message "Plan was successfully changed to GameMaster"
