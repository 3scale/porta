Feature: Personal Details
  In order to keep the information about myself up to date
  As a registered user
  I want to see and change my personal details

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "useraccountarea" enabled
    And a buyer "randomdude" signed up to provider "foo.example.com"


  Scenario: Navigate to personals details page
    When I log in as "randomdude" on foo.example.com
    And I go to the personal details page
    Then I should be on the personal details page


  Scenario: Personal details form
   When I log in as "randomdude" on foo.example.com
   And I go to the personal details page
   Then I should be on the personal details page
   And I should see the personal details form


  Scenario: Edit personal details as buyer
    When I log in as "randomdude" on foo.example.com
      And I go to the personal details page

    When I fill in "Email" with "john.doe@random.example.com"
      And I press "Update Personal Details"
    Then I should see "User was successfully updated"
      And I should be on the personal details page


  Scenario: Editing of personal details can be blocked
    Given provider "foo.example.com" has "useraccountarea" disabled
    When I log in as "randomdude" on foo.example.com
    And I follow "Settings"
    Then I should not see "Personal Details"


  @javascript
  Scenario: User Fields
    Given provider "foo.example.com" has the following fields defined for "User":
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |

    When I log in as "randomdude" on foo.example.com
      And I go to the personal details page

    Then fields should be required:
      | required            |
      | First name          |
      | User extra required |

    Then I should not see the fields:
      | not present          |
      | Last name            |
      | Job role             |
      | User extra read only |
      | User extra hidden    |

    When I press "Update Personal Details"
    Then I should see error in fields:
      | errors              |
      | First name          |
      | User extra required |

    When I fill in "First name" with "dude"
      And I fill in "User extra required" with "whatever"
      And I press "Update Personal Details"
    Then I should see "User was successfully updated"

    Then the "First name" field should contain "dude"
      And the "User extra required" field should contain "whatever"
