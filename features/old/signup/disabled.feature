Feature: Disabled signup for the provider
  In order to close my API to newcomers
  As a provider
  I want to disable signups

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has signup disabled
    And the following account plan:
      | Issuer               | Name   | Default |
      | foo.3scale.localhost | Tier-1 | true    |
      And the current domain is foo.3scale.localhost

  Scenario: I try to enter the URL manually
     When I go to the sign up page
     Then I should see "Signup disabled"

  Scenario: I want to click the signup link
     When I go to the dashboard
     Then I should not see "Sign up"
     And I should not see link to the sign up page
