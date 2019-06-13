Feature: Personal Details
  In order to keep the information about myself up to date
  As a registered user
  I want to see and change my personal details

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled

  Scenario: Edit personal details as provider
   Given current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

   When I go to the provider personal details page
    And I fill in "Email" with "john.doe@foo.example.com"
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    Then I should see "User was successfully updated"
    And I should be on the provider personal details page

  Scenario: Personal details redirects back to users list if originated there
    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
    When I go to the provider users page
      And I follow "foo.example.com" within "#users"
    Then I should be on the provider personal details page
    When I fill in "Email" with "john.doe@foo.example.com"
      And I fill in "Current password" with "supersecret"
      And I press "Update Details"
    Then I should be on the provider users page
    When I follow "foo.example.com" within "#users"
      And I fill in "Email" with ""
      And I fill in "Current password" with "supersecret"
      And I press "Update Details"
      And I fill in "Email" with "john.doe@foo.example.com"
      And I fill in "Current password" with "supersecret"

      And I press "Update Details"
    Then I should be on the provider users page


  @wip
  Scenario: Edit personal details with invalid data
   Given current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"
    And I go to the personal details page

    And I fill in "Email" with ""
    And I press "Update Details"
    Then I should see "can't be blank" within "#user_email_input"

  Scenario: Provider should see all fields defined for user
    Given master provider has the following fields defined for "User":
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |

    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

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
