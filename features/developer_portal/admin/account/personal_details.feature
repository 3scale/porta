Feature: Dev Portal Buyer Personal Details
  As a buyer
  I want to change my personal details

  Background:
    Given a buyer logged in to a provider

  @javascript
  Scenario: Buyer doesn't use current password
    Given the buyer wants to edit their personal details
    When they edit their personal details
    But fill in "Current Password" with ""
    Then they should not be able to edit their personal details

  @javascript
  Scenario: Buyer uses wrong current password
    Given the buyer wants to edit their personal details
    When they edit their personal details
    But fill in "Current Password" with "wrong password"
    Then they should not be able to edit their personal details

  @javascript
  Scenario: Buyer uses correct current password
    Given the buyer wants to edit their personal details
    When they edit their personal details
    And they change their password
    Then they should be able to edit their personal details
    And password has changed

  @javascript
  Scenario: Provider has custom personal details fields
    Given the provider has the following fields defined for "User":
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

    And fill in "Current Password" with "supersecret"
    And they press "Update Personal Details"
    Then they should see error in fields:
      | errors              |
      | First name          |
      | User extra required |

    When the buyer edits their custom personal details
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

  @javascript
  Scenario: Buyer sends a wrong email
    Given the buyer wants to edit their personal details
    When they edit their personal details
    And fill in "Email" with "wrong"
    Then they should not be able to edit the email
