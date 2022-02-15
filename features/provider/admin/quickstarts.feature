@javascript
Feature: Quick Starts

  Background:
    And a provider is logged in

  Rule: Feature is enabled
    Background:
      Given quickstarts is enabled

    Scenario: Header help menu have the option
      Then I should be able to go to the quick start catalog from the help menu

    Scenario: Quick Start catalog
      Given I go to the quick start catalog page
      Then I should be able to start following a quick start from a gallery

    Scenario: Following a Quick Start
      Given I am following a quick start
      When I go anywhere else
      Then I will still be able to see the quick start

    Scenario: Closing a Quick Start
      Given I am following a quick start
      Then I should be able to close it without losing any progress

    Scenario: Restart a Quick Start
      Given I have finished a quick start
      Then I should be able to restart its progress

  Rule: Quickstarts disabled
    Background:
      Given quickstarts is disabled

    Scenario: Header help menu does not have the option
      Then I should not be able to go to the quick start catalog from the help menu

    Scenario: Following a Quick Start does not show it
      Given I am following a quick start
      When I go anywhere else
      Then I won't be able to see the quick start
