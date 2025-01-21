@javascript
Feature: User management
  In order to manage users in my organization
  As an account admin
  I want to have access to user management features

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_applications" visible
    Given an user "alice" of account "foo.3scale.localhost"
    And an user "bob" of account "foo.3scale.localhost"

  Scenario: Edit an user
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider users page
    And I follow "Edit" for user "alice"
    Then I should see "Edit user"
    And I fill in "Email" with "alice@foo.3scale.localhost"
    And I press "Update User"
    Then I should see "User was successfully updated"
    And I should be on the provider users page

  Scenario: Edit an user with invalid data
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider users page
    And I follow "Edit" for user "alice"
    And I fill in "Email" with ""
    And I press "Update User"
    Then I should see "should look like an email address"

  Scenario: Edit user role
    Given user "bob" has role "member"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider users page
    Then I should see "member" that belongs to user "bob"
    When I follow "Edit" for user "bob"
    And I choose "Admin" in the user role field
    And I press "Update User"
    Then user "bob" should have role "admin"

  Scenario: Admin cannot edit his/her own role
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider users page
    And I follow "foo.3scale.localhost"
    Then I should see "Personal details"
    Then I should not see "Role"
