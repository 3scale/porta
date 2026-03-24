Feature: Sign Up of enterprise buyers
  In order to use multiple Providers
  As a buyer
  I want to sign up in different domains with the same name and email

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "multiple_applications" visible
    And the following account plan:
      | Issuer               | Name   |
      | foo.3scale.localhost | Tier-1 |
      And a default service of provider "foo.3scale.localhost" has name "api"
    And the following service plan:
      | Product | Name   |
      | api     | Gold   |
    And the following application plan:
      | Product | Name   |
      | api     | iPhone |

    Given a provider "foo2.3scale.localhost"
    And the following account plan:
      | Issuer               | Name   |
      | foo2.3scale.localhost | Tier-2 |
      And a default service of provider "foo2.3scale.localhost" has name "api2"
    And the following service plan:
      | Product | Name    |
      | api2    | Gold2   |
    And the following application plan:
      | Product | Name    |
      | api2    | iPhone2 |

    Given an approved buyer "bar" signed up to provider "foo.3scale.localhost"

  Scenario: try to signup with existent email in other provider
    When the current domain is foo2.3scale.localhost
      And I signup with the email "bar@example.org"
   Then I should see the registration succeeded

  Scenario: try to signup with existent email in other provider
   When the current domain is foo2.3scale.localhost
     And I go to the sign up page
     And I fill in the following:
      | Email                   | foobar@example.net |
      | Username                | bar                |
      | Password                | superSecret1234#   |
      | Password confirmation   | superSecret1234#   |
      | Organization/Group Name | Planet eXpress     |
     And I press "Sign up"
     And I should see the registration succeeded

     @wip
  Scenario: try to signup with existent username in same provider
    When the current domain is foo.3scale.localhost
      And I go to the sign up page
      And I fill in the following:
      | Email                   | foobar@example.net |
      | Username                | bar                |
      | Password                | superSecret1234#   |
      | Password confirmation   | superSecret1234#   |
      | Organization/Group Name | Planet eXpress     |
    Then I should see error in fields:
      | account errors |
      | Username       |

      @wip
  Scenario: try to signup with existent mail in same provider
    When the current domain is foo.3scale.localhost
      And I go to the sign up page
      And I fill in the following:
      | Email                   | bar@3scale.localhost |
      | Username                | notExistent          |
      | Password                | superSecret1234#     |
      | Password confirmation   | superSecret1234#     |
      | Organization/Group Name | Planet eXpress       |
    Then I should see error in fields:
      | account errors |
      | Email          |
