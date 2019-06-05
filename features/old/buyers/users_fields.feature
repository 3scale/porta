@javascript
Feature: Buyer users fields management
  In order to have an awesome UI
  As a provider
  I want to be able to manage the fields of my users

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And a buyer "SpaceWidgets" signed up to provider "foo.example.com"
    Given provider "foo.example.com" has the following fields defined for "User":
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |


  Scenario: Fields are not required/hidden/read_only for providers
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    When I go to the buyer user edit page for "SpaceWidgets"

    Then fields should be required:
      | required            |
      | First name          |
      | User extra required |

    Then I should see the fields:
      | present              |
      | First name           |
      | Last name            |
      | Job role             |
      | User extra required  |
      | User extra read only |
      | User extra hidden    |

    When I press "Update User"
    Then I should see "User was successfully updated."


  Scenario: Fields edition
    Given current domain is the admin domain of provider "foo.example.com"
     And I am logged in as provider "foo.example.com"
    When I go to the buyer user edit page for "SpaceWidgets"
      And I fill in "First name" with "bob"
      And I fill in "User extra read only" with "notEditable"

    When I press "Update User"
    Then I should see "User was successfully updated."
      And I should see "bob" in the "First name" field
      And I should see "notEditable" in the "User extra read only" field
