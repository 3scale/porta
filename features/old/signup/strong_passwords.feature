Feature: Signup with strong passwords
  In order to force strong passwords
  As a new partner
  I have to enter a strong password

  Background:
    Given a provider "foo.3scale.localhost" with default plans
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name   | Default |
      | My API  | iPhone | true    |
    Given the current domain is foo.3scale.localhost


  Scenario: Strong password is required
    Given provider "foo.3scale.localhost" is requiring strong passwords
    When I go to the sign up page
      And I fill in the following:
       | Email                   | bender@planet.ex |
       | Username                | bender           |
       | Password                | weakpwd          |
       | Password confirmation   | weakpwd          |
       | Organization/Group Name | Planet eXpress   |

       And I press "Sign up"
    Then I should see the error that the password is too weak
