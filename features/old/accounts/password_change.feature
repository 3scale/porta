Feature: Password change
  In order to feel better about my security
  As an user
  I want to change my password from time to time

  @javascript
  Scenario: Provider password change
    Given a provider "foo.3scale.localhost"

    Given current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost" with password "supersecret"
    When I navigate to the Account Settings
    And I follow "Personal"
    And I follow "Personal Details"
    And I fill in "Password" with "monkey"
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    And I log out
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I go to the provider login page
    And I fill in "Email or Username" with "foo.3scale.localhost"
    And I fill in "Password" with "monkey"
    And I press "Sign in"
    Then I should be logged in as "foo.3scale.localhost"
