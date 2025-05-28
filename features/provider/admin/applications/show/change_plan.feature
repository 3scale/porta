@javascript
Feature: Application plan change card

  Background:
    Given a provider is logged in
    And a product "My API"
    And a buyer "Jane"

  Rule: Single application plan
    Background:
      Given the following application plan:
        | Product | Name |
        | My API  | Free |
      And the following application:
        | Buyer | Name   | Product |
        | Jane  | My App | My API  |

    Scenario: Change plan card hidden with one plan only
      Given they go to the application's admin page
      Then they should not be able to see the change plan card

  Rule: Multple application plans
    Background:
      Given the following application plans:
        | Product | Name    |
        | My API  | Free    |
        | My API  | Premium |
      And the following application:
        | Buyer | Name   | Product |
        | Jane  | My App | My API  |

    Scenario: Change plan card visible with multiple plans
      Given they go to the application's admin page
      Then they should see "Change plan" within the change plan card

    Scenario: Change the application plan
      Given they go to the application's admin page
      When they select "Premium" from "Change plan" within the change plan card
      And press "Change" within the change plan card
      Then they should see "Application Plan: Premium"

    Scenario: Change from custom plan
      Given they go to the application's admin page
      And follow "Convert to a Custom Plan" within the plan card
      When they select "Premium" from "Change plan" within the change plan card
      And press "Change" within the change plan card
      Then they should see a toast alert with text "Plan changed to 'Premium'"

    Scenario: Buyer is notified if their plan is changed
      Given they go to the application's admin page
      And they select "Premium" from "Change plan" within the change plan card
      And they press "Change plan" within the change plan card
      When they log out
      And act as "Jane"
      Then they should receive an email with subject "Application plan changed to 'Premium'"
