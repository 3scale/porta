Feature: Disabled signup for the provider
  In order to close my API to newcomers
  As a provider
  I want to disable signups

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has signup disabled
      And a account plan "Tier-1" of provider "foo.example.com"
      And account plan "Tier-1" is default
      And the current domain is foo.example.com

  Scenario: I try to enter the URL manually
     When I go to the sign up page
     Then I should see "Signup disabled"

  Scenario: I want to click the signup link
     When I go to the dashboard
     Then I should not see "Sign up"
     And I should not see link to the sign up page
