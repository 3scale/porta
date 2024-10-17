Feature: Password change
  In order to feel better about my security
  As an user
  I want to change my password from time to time

  @javascript
  Scenario: Provider password change
    Given a provider is logged in
    When I navigate to the Account Settings
    And I go to the provider personal details page
    And I fill in "New password" with "monkey"
    And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    And I log out
    And I go to the provider login page
    And I fill in "Email or Username" with "foo.3scale.localhost"
    And I fill in "Password" with "monkey"
    And I press "Sign in"
    Then I should be logged in as "foo.3scale.localhost"
