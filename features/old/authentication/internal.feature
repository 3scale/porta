Feature: Internal authentication
  In order to use a product of a provider using internal authentication strategy
  As an user
  I want to sign in

  # TODO: Figure out the after-login redirections. Currently, it's fixed to go
  # to the dashboard (providers) or the homepage (buyers), but it might make sense
  # to go to whatever page the user was trying to go before.

  Background:
    Given a provider "foo.3scale.localhost"
    And a default service of provider "foo.3scale.localhost" has name "api"
    And provider "foo.3scale.localhost" has "multiple_applications" visible
    And provider "foo.3scale.localhost" requires cinstances to be approved before use
    And provider "foo.3scale.localhost" requires accounts to be approved

  @wip @3D
  Scenario: Successful sign in as a provider on the master domain
    When current domain is the admin domain of provider "foo.3scale.localhost"
    And I go to the provider login page
    Then I should feel secure
    When I fill in "Username" with "foo.3scale.localhost"
    And I fill in "Password" with "superSecret1234#"
    And I press "Sign in"
    Then I should be logged in as "foo.3scale.localhost"
    And I should be on the provider dashboard

    # TODO: This should be separate scenario
    When I follow "Logout"
    Then I should see "You have been logged out"

  @javascript
  Scenario: Redirects and keeps full url
    # legal terms's  url url has query_string
    Given the admin of account "foo.3scale.localhost" has password "superSecret1234#"
    When current domain is the admin domain of provider "foo.3scale.localhost"
      And I go to the legal terms settings page
    And I fill in "Username" with "foo.3scale.localhost"
    And I fill in "Password" with "superSecret1234#"
    And I press "Sign in"
    Then I should have the following query string:
    | system_name | signup_licence|


  @javascript
  Scenario: Failed attempt to sign in as provider with invalid password
    Given the admin of account "foo.3scale.localhost" has password "superSecret1234#"
    When current domain is the admin domain of provider "foo.3scale.localhost"
    And I go to the provider login page
    And I fill in "Username" with "foo.3scale.localhost"
    And I fill in "Password" with "whatever"
    And I press "Sign in"
    Then I should see "Incorrect email or password. Please try again"

  @wip
  Scenario: Successful sign in as a provider on their domain
    When I go to the login page on foo.3scale.localhost
    And I fill in "Username" with "foo.3scale.localhost"
    And I fill in "Password" with "supersecret"
    And I press "Sign in"
    Then I should be logged in as "foo.3scale.localhost"
    And I should be on the homepage

  Scenario: Successful sign in as a buyer
    Given a buyer "alice" signed up to provider "foo.3scale.localhost"

    When the current domain is foo.3scale.localhost
    And I go to the login page
    And I fill in "Username" with "alice"
    And I fill in "Password" with "superSecret1234#"
    And I press "Sign in"
    Then I should be logged in as "alice"

  @wip @3D
  Scenario: Successful sign in as master account admin
   Given the master account admin has username "admin" and password "superSecret1234#"
    When current domain is the admin domain of provider "foo.3scale.localhost"
    And I go to the provider login page
    And I fill in "Username" with "admin"
    And I fill in "Password" with "superSecret1234#"
    And I press "Sign in"
    Then I should be logged in as "admin"
    And I should be on the provider dashboard

  @wip
  Scenario: Successful sign in stores login time and IP
    Given the time is 8th October 2010, 11:10
    And my remote address is "100.101.102.103"
    When current domain is the admin domain of provider "foo.3scale.localhost"
    And I go to the provider login page
    And I fill in "Username" with "foo.3scale.localhost"
    And I fill in "Password" with "superSecret1234#"
    And I press "Sign in"
    Then user "foo.3scale.localhost" should have last login on 8th October 2010 at 11:10 from 100.101.102.103

  @security
  Scenario: Failed attempt to sign in without being activated
    Given a buyer "wickedwidgets" signed up to provider "foo.3scale.localhost"
    And a pending user "bob" of account "wickedwidgets"
    When the current domain is foo.3scale.localhost
    And I try to log in as "bob"
    Then I should not be logged in

  @security
  Scenario: Failed attempt to sign in as user with pending account
    Given a pending buyer "wickedwidgets" signed up to provider "foo.3scale.localhost"
    When the current domain is foo.3scale.localhost
    And I try to log in as "wickedwidgets"
    Then I should not be logged in

  @security
  Scenario: Failed attempt to sign in as user with rejected account
    Given a rejected buyer "wickedwidgets" signed up to provider "foo.3scale.localhost"
    When the current domain is foo.3scale.localhost
    And I try to log in as "wickedwidgets"
    Then I should not be logged in
