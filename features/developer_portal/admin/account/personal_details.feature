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
  Scenario: Provider has custom personal details fields
    Given provider "foo.3scale.localhost" has the following fields defined for "User":
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |

    When the buyer wants to edit their personal details
    Then fields should be required:
      | required            |
      | First name          |
      | User extra required |

    And they should not see the fields:
      | not present          |
      | Last name            |
      | Job role             |
      | User extra read only |
      | User extra hidden    |

    When the buyer writes a correct current password
    And they press "Update Personal Details"
    Then they should see error in fields:
      | errors              |
      | First name          |
      | User extra required |

    When the buyer edits their custom personal details
    And the buyer writes a correct current password
    Then they should be able to edit their custom personal details

  Scenario: Editing of personal details can be blocked
    Given provider "foo.3scale.localhost" has "useraccountarea" disabled
    And the buyer follow "Settings"
    Then they should not see "Personal Details"

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
