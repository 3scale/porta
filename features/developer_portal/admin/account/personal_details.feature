Feature: Dev Portal Buyer Personal Details
  As a buyer
  I want to change my personal details

  Background:
    Given a provider
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name | Default | Cost per month |
      | My API  | Gold | true    | 100            |
    And an approved buyer "John" signed up to the provider
    And the following application:
      | Buyer | Name   |
      | John  | My App |
    And the buyer logs in

  @javascript
  Scenario: Buyer doesn't use current password
    Given they go to the personal details page
    And the current page is the personal details page
    When they edit their personal details
    But fill in "Current Password" with ""
    Then they should not be able to edit their personal details

  @javascript
  Scenario: Buyer uses wrong current password
    Given they go to the personal details page
    And the current page is the personal details page
    When they edit their personal details
    But fill in "Current Password" with "wrong password"
    Then they should not be able to edit their personal details

  @javascript
  Scenario: Buyer uses correct current password
    Given they go to the personal details page
    And the current page is the personal details page
    When they edit their personal details
    And they change their password
    Then they should be able to edit their personal details
    And password has changed

  @javascript
  Scenario: Provider has custom personal details fields
    Given the provider has the following fields defined for users:
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |
    When they go to the personal details page
    Then fields are required:
      | required            |
      | First name          |
      | User extra required |

    And they should not see the fields:
      | not present          |
      | Last name            |
      | Job role             |
      | User extra read only |
      | User extra hidden    |

    And fill in "Current Password" with "superSecret1234#"
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
    Given they go to the personal details page
    When they don't provide any personal details
    Then they should not be able to edit their personal details

  @javascript
  Scenario: Buyer sends a wrong email
    Given they go to the personal details page
    And the current page is the personal details page
    When they edit their personal details
    And fill in "Email" with "wrong"
    Then they should not be able to edit the email
