Feature: Application Stats

  Background:
    Given a provider is logged in
      And has an application

  @javascript
  Scenario: Stats access
    Given I'm on that application page
    When I follow "Analytics" within the subsubmenu
    Then I should see that application stats
