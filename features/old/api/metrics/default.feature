Feature: Default metrics
  In Order to report transactions of my service
  As a provider
  I should have default metrics created for me

  @javascript
  Scenario: Default metrics available after signup
    Given the master account allows signups
    And a provider signs up and activates his account

    Then I go to the application plans admin page
    And I follow "Create application plan"
    And I fill in "Name" with "Amazing"
    And I press "Create application plan"
    When I follow "Amazing"
    Then I should see metric "Hits"
