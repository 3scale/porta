@javascript
Feature: Activation
  In order to allow only users with valid emails to sign in
  They have to activate themselves first

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"

  @emails
  Scenario: Activation with valid activation token
    Given a pending user "alice" of account "foo.3scale.localhost"
    When I follow the activation link in an email sent to user "alice"
    And I try to log in as provider "alice"
    Then they should see "Hello alice"
    And the current page is the provider onboarding wizard page

  Scenario: Not activated user can't log in
    Given a pending user "alice" of account "foo.3scale.localhost"
    When I try to log in as provider "alice"
    Then I should not be logged in
    And I should see "Your account isn't active or hasn't been approved yet."

  Scenario: Activated user logs in
    Given a pending user "alice" of account "foo.3scale.localhost"
    And user "alice" activates herself
    When I try to log in as provider "alice"
    Then they should see "Hello alice"
    And the current page is the provider onboarding wizard page

  Scenario: Activated user tries to activate again
    Given a pending user "alice" of account "foo.3scale.localhost"
    And user "alice" activates herself
    And user "alice" activates herself
    Then I should be on the provider login page
  #TODO: Check for the content of the activation email
  #TODO: Check for the content of the post-activation screen
  #TODO: Attempt to activate with invalid token
  #TODO: Attempt to activate already activated user
