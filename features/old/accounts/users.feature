Feature: User management
  In order to manage users in my organization
  As an account admin
  I want to have access to user management features

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    Given an user "alice" of account "foo.example.com"
      And an user "bob" of account "foo.example.com"

  Scenario: Navigating to users overview for providers
    And current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"
    When I go to the provider users page
      And go to the provider account page
      And I follow "Users"
    Then I should see "Users"

  Scenario: Users overview for providers
    And current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"
    When I go to the provider users page
    Then I should see user "alice"
      And I should see link to the provider user edit page for "alice"
      And I should see button to delete user "alice"
    And I should see user "bob"
      And I should see link to the provider user edit page for "bob"
      And I should see button to delete user "bob"

  Scenario: Last admin does not have delete button
    And current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"
    When I go to the provider users page
    Then I should see user "foo.example.com"
      But I should not see button to delete user "foo.example.com"

  Scenario: Users overview only shows own users
    Given a provider "bar.example.com"
      And an user "cecilia" of account "bar.example.com"

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I go to the provider users page
    Then I should see "alice"
    But I should not see "cecilia"

  Scenario: Edit an user
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    And I follow "Edit" for user "alice"
    Then I should see "Edit user"
    And I fill in "Email" with "alice@foo.example.com"
    And I press "Update User"
    Then I should see "User was successfully updated"
    And I should be on the provider users page

  Scenario: Edit an user with invalid data
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    And I follow "Edit" for user "alice"
    And I fill in "Email" with ""
    And I press "Update User"
    Then I should see "should look like an email address" within "#user_email_input"

  Scenario: Delete an user
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    Then I press "Delete" for user "alice" and I confirm dialog box
    Then I should see "User was successfully deleted"
    And there should be no user with username "alice" of account "foo.example.com"

  Scenario: Edit user role
    Given user "bob" has role "member"
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    Then I should see "member" for user "bob"
    When I follow "Edit" for user "bob"
    And I choose "Admin" in the user role field
    And I press "Update User"
    Then user "bob" should have role "admin"

  @security @allow-rescue
  Scenario: Only admins can manage users
    Given an active user "josephine" of account "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "josephine"
    And go to the provider account page
    Then I should not see link to the provider users page

    When I go to the provider users page
    Then I should be denied the access

  @allow-rescue
  Scenario: Admin cannot delete him/herself
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    Then I should not see "delete" for user "foo.example.com"

    When I do a HTTP request to delete user "foo.example.com"
    Then I should be denied the access

  Scenario: Admin cannot edit his/her own role
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    And I follow "foo.example.com"
    Then I should see "Personal details"
    Then I should not see "Role"

    When I do a HTTP request to change role of user "foo.example.com" to "member"
    Then user "foo.example.com" should have role "admin"

  @security
  Scenario: User management requires login
    And current domain is the admin domain of provider "foo.example.com"
    And I am not logged in
    When I go to the provider users page
    Then I should be on the provider login page

  Scenario: Lists the users and their permission groups for enabled accounts
    Given provider "foo.example.com" has "groups" switch allowed
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the provider users page
    Then I should see "bob"
