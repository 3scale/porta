Feature: Signup with strong passwords
  In order to force strong passwords
  As a new partner
  I have to enter a strong password

  Background:
    Given a provider "foo.example.com" with default plans
      And an application plan "iPhone" of service "default"
      And application plan "iPhone" is default
    Given the current domain is foo.example.com


  Scenario: Strong password is required
    Given provider "foo.example.com" is requiring strong passwords
    When I go to the sign up page
      And I fill in the following:
       | Email                   | bender@planet.ex |
       | Username                | bender           |
       | Password                | weakpwd          |
       | Password confirmation   | weakpwd          |
       | Organization/Group Name | Planet eXpress   |

       And I press "Sign up"
    Then I should see the error that the password is too weak
