Feature: Dev Portal Buyer Personal Details
  As a buyer
  I want to change my personal details

  Background:
    Given a buyer logged in to a provider using SSO

  Scenario: Buyer shouldn't see any password input 
    Given the buyer wants to edit their personal details
    Then the buyer shouldn't see any reference to password

  @javascript
  Scenario: Buyer can edit their personal details
    Given the buyer wants to edit their personal details
    When the buyer edits their personal details
    Then they should be able to edit their personal details
