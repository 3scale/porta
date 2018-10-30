@selenium @javascript
Feature: As part of the onboarding process
  Providers are given a visual guidance
  marking the suggested steps with bubbles

  Background:
    Given a provider is logged in with onboarding process active
    When visits the default service page

  Scenario: Provider sees bubbles
    Then api bubble should be visible