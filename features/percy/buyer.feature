@percy @javascript @selenium
Feature: Visual Regressions

  Background:
    Given the date is 2015-12-24
      And a provider
      And the provider account allows signups
      And all the rolling updates features are off
      And the provider has a buyer

  Scenario: Buyer Dashboard
    When the buyer has simple API key
    Then I take a screenshot of "the buyer dashboard"

  Scenario: Buyer Stats
    When I go to the buyer stats page
    Then the stats should load
    And I take a screenshot of the current page and name it "the buyer stats page"

  @allow-rescue
  Scenario: The 404 page
    When I visit "/some-missing-page"
    Then I take a screenshot of the current page and name it "the developer portal 404 page"
