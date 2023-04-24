@emails
Feature: Invitations
  In order to allow more people to be users of a provider account
  As an account admin
  I want to invite them

  Background:
    Given a provider is logged in
    And the provider has multiple applications enabled
    And the provider has "multiple_users" switch allowed

  @javascript
  Scenario: Sending an invitation as provider
    And I send a provider invitation to "alice@foo.3scale.localhost"
    Then an invitation with the admin domain of account "foo.3scale.localhost" should be sent to "alice@foo.3scale.localhost"
