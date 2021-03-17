Feature: Default metrics
  In Order to report transactions of my service
  As a provider
  I should have default metrics created for me

  @wip @3D
  Scenario: Default metrics available after signup
    Given provider "master" has default service and account plan
    When new provider "bar.3scale.localhost" signs up and activates
      And current domain is the admin domain of provider "bar.3scale.localhost"
      And I log in as provider "bar.3scale.localhost"
    And I go to the application plans admin page
      And I follow "Create new plan"
      And I fill in "Name" with "Amazing"
      And I press "Create Application plan"
    When I follow "Edit"
      Then I should see metric "Hits"
