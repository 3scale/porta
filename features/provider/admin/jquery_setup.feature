@javascript
Feature: jQuery setup
  The admin portal loads jQuery 3 as the global $ and isolates jQuery 1 with
  colorbox as window.jQuery1. This test verifies the setup is correct.

  Background:
    Given a provider is logged in

  Scenario: jQuery 3 is the global jQuery
    Then the global jQuery version should be "3"

  Scenario: jQuery 1 with colorbox is available as jQuery1
    Then window.jQuery1 should be available
    And window.jQuery1 should have colorbox
