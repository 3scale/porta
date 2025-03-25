@javascript
Feature: Buyer account overview

  Background:
    Given a provider is logged in
    And the provider has "account_plans" allowed
    And an approved buyer "Bob Buyer"

  Scenario: Sending a message
    Given buyer "Bob Buyer" has no messages
    And they go to the buyer account page for "Bob Buyer"
    When they follow "Send message"
    And fill in "Subject" with "Party tonite!"
    And fill in "Body" with "You are invited to my party."
    And the "To" field should be fixed to "Bob Buyer"
    And press "Send"
    Then should see "Message was sent."

  Rule: Account plans hidden
    Background:
      Given the provider has "account_plans" hidden

    Scenario: Can't change the account plan
      When they go to buyer "Bob Buyer" overview page
      Then they should not see "Change Plan"

  Rule: Account plans visible
    Background:
      Given the provider has "account_plans" visible

    Scenario: Customizing the account plan
      And they go to buyer "Bob Buyer" overview page
      When they follow "Convert to a Custom Plan"
      Then they should see the flash message "Plan customized."
      And should see "Custom Account Plan" within the plan card
      And there should be a link to "Edit" within the plan card
      And there should be a button to "Remove customization" within the plan card

    Scenario: Decustomizing the account plan
      And the buyer uses a custom plan "Banana Plan"
      And they go to buyer "Bob Buyer" overview page
      When they press "Remove customization" within the plan card
      Then they should see the flash message "The plan was set back to Banana Plan."
      And there should be a link to "Convert to a Custom Plan" within the plan card

    Scenario: Changing the account plan
      Given the following account plan:
        | Issuer               | Name     | State     |
        | foo.3scale.localhost | Advanced | Published |
      Given they go to buyer "Bob Buyer" overview page
      When they select "Advanced" from "account_contract_plan_id"
      And press "Change"
      And confirm the dialog
      Then they should see the flash message "Plan changed to 'Advanced'"
