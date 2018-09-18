@javascript @selenium
Feature: Member permissions
  As a provider
  I want manage member's permissions

  Background:
      Given a provider with one active member is logged in
      And provider "foo.example.com" has "groups" switch allowed

  Scenario: Enable and disable billing section
    When I have opened edit page for the active member
      Then no permissions should be checked
    When I check "Billing"
      And I press "Update User"
      And I have opened edit page for the active member
      Then the "Billing" checkbox should be checked
    When I uncheck "Billing"
      And I press "Update User"
      And I have opened edit page for the active member
      Then no permissions should be checked
