@javascript
Feature: Audience > Accounts > New

  Background:
    Given a provider is logged in

  Scenario: Navigation
    Given they go to the provider dashboard
    When they follow "0 Accounts" within the audience dashboard widget
    And follow "Add your first account"
    Then the current page is the new buyer account page

  Scenario: Creating an account
    Given they go to the new buyer account page
    And the form is submitted with:
      | Username                | alice              |
      | Email                   | alice@example.com  |
      | Organization/Group Name | Alice's Web Widget |
    Then they should see a toast alert with text "Developer account was successfully created"
    Then the current page is the buyer account page for "Alice's Web Widget"

  Scenario: Creating an account without legal terms
    Given the provider has no legal terms
    When they go to the new buyer account page
    And the form is submitted with:
      | Organization/Group Name | Alice's Web Widget |
      | Username                | alice              |
      | Email                   | alice@example.com  |
    Then they should see a toast alert with text "Developer account was successfully created"
    And the current page is the buyer account page for "Alice's Web Widget"
    And account "Alice's Web Widget" should be approved
    And user "alice" should be active
    But "alice@web-widgets.com" should receive no emails

  Scenario: Fields validation
    Given they go to the new buyer account page
    When the form is submitted with:
      | Username | u                  |
      | Email    | invalid            |
      | Password | superSecret1234#   |
      | Organization/Group Name | Org |
    Then field "Username" has inline error "is too short"
    And field "Email" has inline error "should look like an email address"
    But field "Password" has no inline error

  Scenario: Create account with fields with choices
    Given the provider has the following fields defined for accounts:
      | Name                 | Choices                 | Label                  | Required | Read only | Hidden |
      | country              |                         | Country                | true     |           |        |
      | field_with_choices   | hello, option1, option2 | Fields with choices    | true     |           |        |

    When they go to the new buyer account page
    And there is a select "Country" that includes options:
      | Spain |
      | United States of America |
    And there is a select "Fields with choices" that includes options:
      | hello   |
      | option1 |
      | option2 |
    And the form is submitted with:
      | Username                | alice              |
      | Email                   | alice@example.com  |
      | Organization/Group Name | Alice's Web Widget |
      | Country                 | Spain              |
      | Fields with choices     | option1            |
      | Password                | superSecret1234#   |

    Then the current page is the buyer account page for "Alice's Web Widget"
    And the inverted table has the following rows within the account details card:
      | Country | Spain |
      | Fields with choices | option1 |
