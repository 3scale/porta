@javascript
Feature: Personal Details
  In order to keep the information about myself up to date
  As a registered user
  I want to see and change my personal details

  Background:
    Given a provider is logged in
    And the provider has multiple applications enabled

  Scenario: Edit personal details as provider
    When I navigate to the Account Settings
    And I go to the provider personal details page
    And I fill in "Email" with "john.doe@foo.3scale.localhost"
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    Then I should see "User was successfully updated"
    And I should be on the provider personal details page

  Scenario: Personal details redirects back to users list if originated there
    When I go to the provider users page
    And I follow "Listing"
    And I follow "foo.3scale.localhost" within "#users"
    Then I should be on the provider personal details page
    When I fill in "Email" with "john.doe@foo.3scale.localhost"
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    Then I should be on the provider users page
    When I follow "foo.3scale.localhost" within "#users"
    And I fill in "Email" with ""
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    And I fill in "Email" with "john.doe@foo.3scale.localhost"
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    Then I should be on the provider users page

  Scenario: Edit personal details with invalid data
    And a buyer "randomdude" signed up to provider "foo.3scale.localhost"
    When I log in as "randomdude" on foo.3scale.localhost
    And I go to the personal details page
    Then I should be on the personal details page
    And I fill in "Email" with ""
    And I press "Update Personal Details"
    Then I should see "should look like an email addres"

  Scenario: Provider should see all fields defined for user
    Given master provider has the following fields defined for "User":
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
      | present              |
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
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    Then I should see "User was successfully updated"
    Then the "First name" field should contain "dude"
    And the "User extra required" field should contain "whatever"
