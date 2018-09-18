@emails
Feature: Invitations
  In order to allow more people to be users of a provider account
  As an account admin
  I want to invite them

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "multiple_users" switch allowed

  Scenario: Sending an invitation as provider
    Given the admin domain of provider "foo.example.com" is "admin.foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      When I log in as provider "foo.example.com"
      And I send a provider invitation to "alice@foo.example.com"
    Then an invitation with the admin domain of account "foo.example.com" should be sent to "alice@foo.example.com"
