Feature: Login feature
  In order to have a better site experience
  I want to have a cool login behaviour

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And a buyer "bob" signed up to provider "foo.example.com"

  Scenario: Buyer lands on the homepage when in enterprise mode
     When I log in as "bob" on foo.example.com
     Then I should be on the homepage

  @javascript
  Scenario: Provider lands in dashboard when login in master domain
    When I log in as "foo.example.com" on the admin domain of provider "foo.example.com"
    Then I should be on the provider dashboard

  @wip @3D
  Scenario: Provider lands in admin dashboard when he requests admin login page
    Given current domain is the admin domain of provider "foo.example.com"
    And I am logged in as "foo.example.com"
    When I request the login page
    Then I should be on the dashboard
    And the current domain should be the master domain

  @javascript
  Scenario: Provider lands in admin dashboard when he requests public login page
   Given current domain is the admin domain of provider "foo.example.com"
     And I am logged in as provider "foo.example.com"
    When I go to the provider login page
    Then I should be on the provider dashboard

  Scenario: Buyer lands in dashboard when he requests login page
   Given the current domain is foo.example.com
     And I log in as "bob" on foo.example.com
     And I go to the login page
    Then I should be on the dashboard

  @security @javascript
  Scenario: Buyer cannot login in admin domain
    And current domain is the admin domain of provider "foo.example.com"
    When I try to log in as provider "bob" with password "supersecret"
    Then I should not be logged in
     And I should see "Incorrect email or password. Please try again."

  @security
  Scenario: Provider cannot login in buyer domain
    Given the current domain is foo.example.com
    When I try to log in as "foo.example.com" with password "supersecret"
    Then I should not be logged in
     And I should see "Incorrect email or password. Please try again."
