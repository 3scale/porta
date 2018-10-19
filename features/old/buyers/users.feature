Feature: Buyer users management
  In order to have control over the users of my buyers
  As a provider
  I want to be able to manage the users

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled

    And a buyer "SpaceWidgets" signed up to provider "foo.example.com"
    And an active user "alice" of account "SpaceWidgets"
    And an active user "bob" of account "SpaceWidgets"

    And current domain is the admin domain of provider "foo.example.com"
    And I am logged in as provider "foo.example.com"

 Scenario: Navigating to page of users of a buyer
   When I navigate to the accounts page
     And I follow "SpaceWidgets"
     And I follow "Users"
   Then I should see "Users of SpaceWidgets"

 Scenario: Listing users
   When I go to the buyer users page for "SpaceWidgets"
   Then I should see buyer user "bob"
     And I should see link to the buyer user edit page for "bob"

   And I should see buyer user "alice"
     And I should see link to the buyer user edit page for "alice"

  Scenario: Last admin does not have delete button
    When I go to the buyer users page for "SpaceWidgets"
    Then I should see buyer user "SpaceWidgets"
      And I should see link to the buyer user edit page for "SpaceWidgets"
      When I follow "Edit"
      Then I should not see "Delete"


  Scenario: User details
    When I go to the buyer users page for "SpaceWidgets"
    And I follow "bob"
    Then I should see "User bob of buyer account SpaceWidgets" in a header
    And I should see button to suspend buyer user "bob"
    And I should see link to the buyer user edit page for "bob"
    When I follow "Edit"
    And I should see "Delete"

  Scenario: Edit buyer user
    When I go to the buyer user page for "bob"
    And I follow "Edit"
    And I fill in "Email" with "smith@example.net"
    And I press "Update User"
    Then I should be on the buyer user page for "bob"
    And I should see "smith@example.net"

  @javascript
  Scenario: Delete buyer user
    When I go to the buyer user page for "bob"
    And I follow "Edit"
    Then I follow "Delete" and I confirm dialog box
    # TODO: confirm step here
    Then I should be on the buyer users page for "SpaceWidgets"
    And I should not see buyer user "bob"
    And there should be no user with username "bob" of account "SpaceWidgets"

  Scenario: Suspend and unsuspend buttons on the user list
     And user "bob" is suspended
    When I go to the buyer users page for "SpaceWidgets"

    Then I should see button to unsuspend buyer user "bob"
    And I should not see button to suspend buyer user "bob"

    And I should see button to suspend buyer user "alice"
    And I should not see button to unsuspend buyer user "alice"

  Scenario: Suspend an user
    When I go to the buyer user page for "bob"
    And I press the button to suspend the user
    Then I should see "User was suspended"
    And user "bob" should be suspended

  Scenario: Unsuspend an user
     And user "bob" is suspended
    When I go to the buyer user page for "bob"
    And I press the button to unsuspend the user
    Then I should see "User was unsuspended"
    And user "bob" should be active

  Scenario: Editing buyer user roles
    Given user "bob" has role "member"
      And I navigate to the edit page of user "bob" of buyer "SpaceWidgets"
      And I choose "Admin" in the user role field
      And I press "Update User"
    Then I should see "admin" within the "Role" row
    When I follow "Edit"
      And I choose "Member" in the user role field
      And I press "Update User"
    Then I should see "member" within the "Role" row

  Scenario: Editing role of the only buyer admin
    Given buyer "SpaceWidgets" has only one admin "alice"
    When current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    And I navigate to the edit page of user "alice" of buyer "SpaceWidgets"
    Then I should not see the user role field

  Scenario: Fields are not required/hidden/read_only for Provider when editing users
    Given provider "foo.example.com" has the following fields defined for "User":
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |

    When I go to the buyer user edit page for "alice"

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

  Scenario: Fields edition by provider
    Given provider "foo.example.com" has the following fields defined for "User":
      | name                 | required | read_only | hidden |
      | first_name           | true     |           |        |
      | last_name            |          | true      |        |
      | job_role             |          |           | true   |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |

    When I go to the buyer user edit page for "alice"
      And I fill in "First name" with "bob"
      And I fill in "User extra read only" with "notEditable"
    When I press "Update User"
    Then I should see "User was successfully updated."
      And I should see "bob" in the "First name" field
      And I should see "notEditable" in the "User extra read only" field
