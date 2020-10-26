Feature: Login feature
  In order to have a better site experience
  I want to have a cool login behaviour

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And a buyer "bob" signed up to provider "foo.3scale.localhost"

  @security
  Scenario: Buyer can log in with csrf protection enabled
    Given the current domain is foo.3scale.localhost
    When I go to the login page
     And I fill in the "bob" login data
    Then I should be logged in the Development Portal
