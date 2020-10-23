@javascript
Feature: Member permissions
  As a provider
  I want manage member's permissions

  Background:
      Given a provider with one active member is logged in
      And provider "foo.3scale.localhost" has "groups" switch allowed

  Scenario: Enable and disable billing section
    When I have opened edit page for the active member
      Then no permissions should be checked
    When I check "Setup and manage customer billing"
      And I press "Update User"
      And I have opened edit page for the active member
      Then the "Setup and manage customer billing" checkbox should be checked
    When I uncheck "Setup and manage customer billing"
      And I press "Update User"
      And I have opened edit page for the active member
      Then no permissions should be checked
