Feature: Dev Portal Buyer Personal Details
  As a buyer
  I want to change my personal details

  Background:
    Given Provider has setup RH SSO
    And As a developer, I login through RH SSO
    Given the Oauth2 user has all the required fields
    When I authenticate by Oauth2
    # And a buyer logged in with SSO

  Scenario: Buyer shouldn't see any password input 
    Given the buyer wants to edit their personal details
    Then the buyer shouldn't see any reference to password

  @javascript
  Scenario: Buyer can edit their personal details
    Given the buyer wants to edit their personal details
    When the buyer with SSO edits their personal details
    Then with SSO they should be able to edit their personal details
