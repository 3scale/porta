@javascript
Feature: Member permissions
  As a provider
  I want manage member's permissions

  Background:
    Given a provider is logged in
    And an active user "alex" of account "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "groups" switch allowed

  Scenario: Enable and disable billing section
    When go to the provider user edit page for "alex"
      Then no permissions should be checked
    When I check "Setup and manage customer billing"
      And I press "Update User"
      And go to the provider user edit page for "alex"
      Then the "Setup and manage customer billing" checkbox should be checked
    When I uncheck "Setup and manage customer billing"
      And I press "Update User"
      And go to the provider user edit page for "alex"
      Then no permissions should be checked
