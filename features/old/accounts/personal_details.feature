@javascript
Feature: Personal Details
  In order to keep the information about myself up to date
  As a registered user
  I want to see and change my personal details

  Background:
    Given a provider is logged in
    And the provider has "multiple_applications" visible

  Scenario: Edit personal details as provider
    When I navigate to the Account Settings
    And I go to the provider personal details page
    And I fill in "Email" with "john.doe@foo.3scale.localhost"
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then I should see "User was successfully updated"
    And I should be on the provider personal details page

  Scenario: Personal details redirects back to users list if originated there
    When I go to the provider users page
    And I follow "Listing"
    And I follow "foo.3scale.localhost"
    Then I should be on the provider personal details page
    When I fill in "Email" with "john.doe@foo.3scale.localhost"
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then I should be on the provider users page
    When I follow "foo.3scale.localhost" within the table
    And I fill in "Email" with ""
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    And I fill in "Email" with "john.doe@foo.3scale.localhost"
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then I should be on the provider users page
    And I should see the flash message "User was successfully updated"

  Scenario: Edit personal details with invalid data
    When I navigate to the Account Settings
    And I go to the provider personal details page
    And I fill in "Username" with "u"
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then field "Username" has inline error "is too short (minimum is 3 characters)"

  Scenario: Provider should see all fields defined for user
    Given master provider has the following fields defined for users:
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |
    When I go to the provider personal details page
    Then fields should be required:
      | required            |
      | First name          |
      | User extra required |
      | Current password    |

    Then I should see the fields:
      | First name           |
      | Last name            |
      | Job role             |
      | User extra required  |
      | User extra read only |
      | User extra hidden    |
    When I press "Update Details"
    Then I should not see error in fields:
      | errors              |
      | First name          |
      | User extra required |
    When I fill in "First name" with "dude"
    And I fill in "User extra required" with "whatever"
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then I should see "User was successfully updated"
    Then the "First name" field should contain "dude"
    And the "User extra required" field should contain "whatever"

  Scenario: Update own password when the user was signed up with password
    Given the user was signed up with password
    When I navigate to the Account Settings
    And I go to the provider personal details page
    And I fill in "New password" with "superSecret1234!"
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then I should see "User was successfully updated"

  Scenario: Update own password to a weak password
    Given the user was signed up with password
    When I navigate to the Account Settings
    And I go to the provider personal details page
    And I fill in "New password" with "hi"
    And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then I should see the error that the password is too weak
