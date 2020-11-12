@security
Feature: Security constraints to invite partners
   In order to have the invitations on partner accounts protected from unauthorized users
   Partner invitations are not allowed for users of buyer accounts


  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has the following buyers:
      | Name     |
      | lol cats |
    And an user "lolycat" of account "lol cats"
    And the user "lolycat" is activated


  Scenario: Invitation interface on partners is restricted to users not admins of the provider account
    When I log in as "lolycat" on "foo.3scale.localhost"
    When I request the url of the invitations of the partner "lol cats"
    Then I should see "Not found"
