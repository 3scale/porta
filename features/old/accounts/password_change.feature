Feature: Password change
  In order to feel better about my security
  As an user
  I want to change my password from time to time

  Scenario: Provider password change
    Given a provider "foo.example.com"

    Given current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com" with password "supersecret"
    When I follow "Personal Settings"
    And I follow "Personal Details"
    And I fill in "Password" with "monkey"
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"

    When I follow "Logout"
    And current domain is the admin domain of provider "foo.example.com"
    And I go to the provider login page
    And I fill in "Email or Username" with "foo.example.com"
    And I fill in "Password" with "monkey"
    And I press "Sign in"
    Then I should be logged in as "foo.example.com"
