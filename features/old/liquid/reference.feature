@javascript
Feature: Liquid drops
  In order to be able to edit CMS template efficiently
  as a Provider
  I want to browse the liquid reference

  Background:
    Given a provider is logged in

  Scenario: Access liquid reference
    When I go to the liquid reference
    # TODO: assert by a specific step
    Then I should see "Drops"
    And I should see "Tags"
    And I should see "Filters"
