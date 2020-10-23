Feature: Login feature
  In order to have a better site experience
  I want to have a cool login behaviour

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And a buyer "bob" signed up to provider "foo.3scale.localhost"

  Scenario: Buyer lands on the homepage when in enterprise mode
     When I log in as "bob" on foo.3scale.localhost
     Then I should be on the homepage

  @javascript
  Scenario: Provider lands in dashboard when login in master domain
    When I log in as "foo.3scale.localhost" on the admin domain of provider "foo.3scale.localhost"
    Then I should be on the provider dashboard

  @wip @3D
  Scenario: Provider lands in admin dashboard when he requests admin login page
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as "foo.3scale.localhost"
    When I request the login page
    Then I should be on the dashboard
    And the current domain should be the master domain

  @javascript
  Scenario: Provider lands in admin dashboard when he requests public login page
   Given current domain is the admin domain of provider "foo.3scale.localhost"
     And I am logged in as provider "foo.3scale.localhost"
    When I go to the provider login page
    Then I should be on the provider dashboard

  Scenario: Buyer lands in dashboard when he requests login page
   Given the current domain is "foo.3scale.localhost"
     And I log in as "bob" on "foo.3scale.localhost"
     And I go to the login page
    Then I should be on the dashboard

  @security @javascript
  Scenario: Buyer cannot login in admin domain
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I try to log in as provider "bob" with password "supersecret"
    Then I should not be logged in
     And I should see "Incorrect email or password. Please try again."

  @security
  Scenario: Provider cannot login in buyer domain
    Given the current domain is "foo.3scale.localhost"
    When I try to log in as "foo.3scale.localhost" with password "supersecret"
    Then I should not be logged in
     And I should see "Incorrect email or password. Please try again."
