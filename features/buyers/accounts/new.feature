@javascript
Feature: Audience > Accounts > New

  Background:
    Given a provider is logged in

  Scenario: Navigation
    When they follow "0 Accounts" in the audience dashboard widget
    And follow "Add your first account"
    Then the current page is the new buyer account page

  Scenario: Creating an account
    Given they go to the new buyer account page
    And the form is submitted with:
      | Username                | alice              |
      | Email                   | alice@example.com  |
      | Organization/Group Name | Alice's Web Widget |
    Then the current page is the buyer account page for "Alice's Web Widget"

  Scenario: Creating an account without legal terms
    Given the provider has no legal terms
    When they go to the new buyer account page
    And the form is submitted with:
      | Organization/Group Name | Alice's Web Widget |
      | Username                | alice              |
      | Email                   | alice@example.com  |
    Then the current page is the buyer account page for "Alice's Web Widget"
    And account "Alice's Web Widget" should be approved
    And user "alice" should be active
    But "alice@web-widgets.com" should receive no emails

  Scenario: Require fields and fields validation
    Given they go to the new buyer account page
    When press "Create"
    Then "Username" shows error "is too short"
    And "Email" shows error "should look like an email address"
    And "Organization/Group Name" shows error "can't be blank"
    But "Password" doesn't show any error
