@javascript
Feature: jQuery setup
  The admin portal loads jQuery 3 as the global $

  Background:
    Given a provider is logged in

  Scenario: jQuery 3 is the global jQuery
    Then the global jQuery version should be "3"
