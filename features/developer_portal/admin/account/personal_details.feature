Feature: Dev Portal Buyer Personal Details
  As a buyer
  I want to change my personal details

  Background:
    Given a buyer logged in to a provider

  Scenario: Buyer wants to update information without current password
    Given the buyer wants to edit their personal details
    When the buyer writes a new name
    And the buyer writes a new email
    And clicks on update personal details
    Then they should see current password is incorrect

  Scenario: Buyer wants to update information adding their current password
    Given the buyer wants to edit their personal details
    When the buyer writes a new name
    And the buyer writes a new email
    And the buyer writes their current password
    And clicks on update personal details
    Then they should see their information updated

  Scenario: Buyer wants to update their password without current password
    Given the buyer wants to edit their personal details
    When the buyer writes a new password
    And the buyer confirms their new password
    And clicks on update personal details
    Then they should see current password is incorrect

  Scenario: Buyer wants to update their password adding their current password
    Given the buyer wants to edit their personal details
    When the buyer writes their current password
    And the buyer writes a new password
    And the buyer confirms their new password
    And clicks on update personal details
    Then they should have their password updated
