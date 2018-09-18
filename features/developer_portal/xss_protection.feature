Feature: XSS protection
  As a buyer
  I want to be safe against XSS attacks

  Background:
    Given a provider exists
    And the provider has a default free application plan
    And a buyer signed up to the provider

  @javascript @selenium
  Scenario: Inline javascript attempted into error messages rendered
    When the buyer logs in to the provider
    And I open an URL with XSS exploit
    Then I should see "Granularity must be one of [:month, :day, 21600 seconds, :hour], not 123<img src='1' onerror='confirm(/XSS/)'>"

