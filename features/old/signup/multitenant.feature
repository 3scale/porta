Feature: Sign Up of enterprise buyers
  In order to use multiple Providers
  As a buyer
  I want to sign up in different domains with the same name and email

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And a account plan "Tier-1" of provider "foo.3scale.localhost"
      And a default service of provider "foo.3scale.localhost" has name "api"
      And a service plan "Gold" for service "api" exists
      And an application plan "iPhone" of service "api"

    Given a provider "foo2.3scale.localhost"
      # And provider "foo2.3scale.localhost" has multiple applications enabled
      And a account plan "Tier-2" of provider "foo2.3scale.localhost"
      And a default service of provider "foo2.3scale.localhost" has name "api2"
      And a service plan "Gold2" for service "api2" exists
      And an application plan "iPhone2" of service "api2"

    Given an approved buyer "bar" signed up to provider "foo.3scale.localhost"

  Scenario: try to signup with existent email in other provider
    When the current domain is "foo2.3scale.localhost"
      And I signup with the email "bar@example.org"
   Then I should see the registration succeeded

  Scenario: try to signup with existent email in other provider
   When the current domain is "foo2.3scale.localhost"
     And I go to the sign up page
     And I fill in the following:
      | Email                   | foobar@example.net |
      | Username                | bar           |
      | Password                | supersecret      |
      | Password confirmation   | supersecret      |
      | Organization/Group Name | Planet eXpress   |
     And I press "Sign up"
     And I should see the registration succeeded

     @wip
  Scenario: try to signup with existent username in same provider
    When the current domain is "foo.3scale.localhost"
      And I go to the sign up page
      And I fill in the following:
      | Email                   | foobar@example.net |
      | Username                | bar           |
      | Password                | supersecret      |
      | Password confirmation   | supersecret      |
      | Organization/Group Name | Planet eXpress   |
    Then I should see error in fields:
      | account errors |
      | Username       |

      @wip
  Scenario: try to signup with existent mail in same provider
    When the current domain is "foo.3scale.localhost"
      And I go to the sign up page
      And I fill in the following:
      | Email                   | bar@3scale.localhost |
      | Username                | notExistent        |
      | Password                | supersecret        |
      | Password confirmation   | supersecret        |
      | Organization/Group Name | Planet eXpress   |
    Then I should see error in fields:
      | account errors |
      | Email          |
