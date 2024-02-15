@javascript
Feature: Buyer signups to service
  In order to create applications for specific service
  As a buyer
  I want to signup up to specific service

  Background:
    Given a provider "foo.3scale.localhost" with default plans
      And a default service of provider "foo.3scale.localhost" has name "API"
      And the current domain is foo.3scale.localhost

  Scenario: Signup with approval required
    Given the following service plan:
      | Product | Name | Default | Requires approval |
      | API     | Gold | True    | true              |
     When I go to the sign up page
      And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      And the account "hugo's stuff" should have a pending service contract with the plan "Gold"

  Scenario: Signup without approval required
    Given the following service plan:
      | Product | Name | Default | Requires approval |
      | API     | Gold | True    | false             |
     When I go to the sign up page
      And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      And the account "hugo's stuff" should have a live service contract with the plan "Gold"
