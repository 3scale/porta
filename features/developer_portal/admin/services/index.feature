Feature: Dev portal services

  As a buyer I want to subscribe to a provider products.
  I also want to review and change the plans I am subscribed to.

  Background: Background name
    Given a provider
    And the provider has "multiple_services" visible
    And the provider has "service_plans" allowed
    And a product "dcc-rpg-wiki" with no service plans
    And a buyer "Jane Goodman"
    And the buyer logs in

  Scenario: Can't subscribe to a product with no public or default plans
    Given the buyer is not subscribed to product "dcc-rpg-wiki"
    And the following service plan:
      | Product      | Name        | Default | State  |
      | dcc-rpg-wiki | Secret plan | false   | hidden |
    When they go to the the services list for buyers
    Then there shouldn't be a link to "Subscribe to dcc-rpg-wiki"

  Scenario: Subscribe to a product with a hidden, default plan
    Given the buyer is not subscribed to product "dcc-rpg-wiki"
    And the following service plan:
      | Product      | Name        | Default | State  |
      | dcc-rpg-wiki | Secret plan | true    | hidden |
    When they go to the the services list for buyers
    And follow "Subscribe to dcc-rpg-wiki"
    Then the buyer should be subscribed to product "dcc-rpg-wiki"

  Scenario: Subscribe to a product with a public plan
    Given the buyer is not subscribed to product "dcc-rpg-wiki"
    And the following service plan:
      | Product      | Name        | Default | State     |
      | dcc-rpg-wiki | Public plan | false   | Published |
    When they go to the the services list for buyers
    And follow "Subscribe to dcc-rpg-wiki"
    Then the buyer should be subscribed to product "dcc-rpg-wiki"

  @wip
  Scenario: Services page is hidden

  @wip
  Scenario: User can't manage service contracts

  Rule: Service plans feature is hidden
    Background:
      Given the provider has "service_plans" hidden

    Scenario: Can't change the service plan
      Given the provider allows to change service plan directly
      And the following service plans:
        | Product      | Name       | State     | Default |
        | dcc-rpg-wiki | Player     | Published | true    |
        | dcc-rpg-wiki | GameMaster | Published |         |
      And the buyer is subscribed to product "dcc-rpg-wiki"
      When they go to the the services list for buyers
      Then they should see "dcc-rpg-wiki"
      But there should not be a link to "Review/Change"

  @javascript
  Rule: Service plans feature is visible
    Background:
      Given the provider has "service_plans" visible
      And the following service plans:
        | Product      | Name       | State     | Default |
        | dcc-rpg-wiki | Player     | Published | true    |
        | dcc-rpg-wiki | GameMaster | Published |         |
      And the buyer is subscribed to product "dcc-rpg-wiki"

    Scenario: Changing a service plan directly
      Given the provider allows to change service plan directly
      And they go to the the services list for buyers
      When they follow "Review/Change"
      And follow "GameMaster"
      And press "Change Plan"
      Then they should see the flash message "Plan was successfully changed to GameMaster."

    Scenario: Requesting a service plan change
      Given the provider allows to change service plan by request
      And they go to the the services list for buyers
      When they follow "Review/Change"
      And follow "GameMaster"
      And press "Request Plan Change"
      Then they should see the flash message "A request to change your service plan has been sent."

    Scenario: Plan change is requested without a credit card
      Given the provider allows to change service plan only with credit card
      And they go to the the services list for buyers
      When they follow "Review/Change"
      And follow "GameMaster"
      And press "Request Plan Change"
      Then they should see the flash message "A request to change your service plan has been sent."

    Scenario: Plan can be changed directly with a credit card
      Given the provider allows to change service plan only with credit card
      And the buyer has a valid credit card
      And they go to the the services list for buyers
      When they follow "Review/Change"
      And follow "GameMaster"
      And press "Change Plan"
      Then they should see the flash message "Plan was successfully changed to GameMaster."
