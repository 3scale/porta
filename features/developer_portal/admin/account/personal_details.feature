Feature: Dev Portal Buyer Personal Details
  As a buyer
  I want to change my personal details

  Background:
    Given a buyer logged in to a provider

  # This is needed, otherwise assert_flash doesn't receive the right message.
  # Check flash-buyer.js
  @javascript
  Scenario: Buyer doesn't use current password
    Given the buyer wants to edit their personal details
    When the buyer edits their personal details
    Then they should not be able to edit their personal details

  @javascript
  Scenario: Buyer uses wrong current password
    Given the buyer wants to edit their personal details
    When the buyer edits their personal details
    And the buyer writes a wrong current password
    Then they should not be able to edit their personal details

  @javascript
  Scenario: Buyer uses correct current password
    Given the buyer wants to edit their personal details
    When the buyer edits their personal details
    And the buyer writes a correct current password
    Then they should be able to edit their personal details

  @javascript
  Scenario: Buyer sends an empty form
    Given the buyer wants to edit their personal details
    When they don't provide any personal details
    Then they should not be able to edit their personal details

  Scenario: Buyer sends a wrong email
    Given the buyer wants to edit their personal details
    When fill in "Email" with "email"
    And the buyer writes a correct current password
    Then they should see email errors
