Feature: Application Stats

  Background:
    Given a provider is logged in
      And has an application

  Scenario: Stats access
    Given I'm on that application page
    When I follow "Analytics"
    Then I should see that application stats
