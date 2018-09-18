@javascript
Feature: Buyer signups to service
  In order to create applications for specific service
  As a buyer
  I want to signup up to specific service

  Background:
    Given a provider "foo.example.com" with default plans
      And a default service of provider "foo.example.com" has name "API"
      And a service plan "Gold" for service "API" exists
      And the current domain is foo.example.com

  Scenario: Signup with approval required
    Given service plan "Gold" is default
      And service plan "Gold" requires approval of contracts
     When I go to the sign up page
      And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      And the account "hugo's stuff" should have a pending service contract with the plan "Gold"

  Scenario: Signup without approval required
    Given service plan "Gold" is default
     When I go to the sign up page
      And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      And the account "hugo's stuff" should have a live service contract with the plan "Gold"
