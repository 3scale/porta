@emails
Feature: Invitations
  In order to allow more people to be users of a provider account
  As an account admin
  I want to invite them

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "multiple_users" switch allowed

  @javascript
  Scenario: Sending an invitation as provider
    Given the admin domain of provider "foo.3scale.localhost" is "admin.foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
      When I log in as provider "foo.3scale.localhost"
      And I send a provider invitation to "alice@foo.3scale.localhost"
    Then an invitation with the admin domain of account "foo.3scale.localhost" should be sent to "alice@foo.3scale.localhost"
