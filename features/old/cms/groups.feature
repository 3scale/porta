@javascript
Feature: CMS groups
  As a provider I want to be able to manage buyer groups and their permissions

  Background:
    Given a provider is logged in
    And the provider has "groups" switch allowed
    And provider "foo.3scale.localhost" has a private section "nothing-to-see-here"
    When I go to the groups page

  Scenario: Only display private sections
    When I follow "Create Group"
    Then I should see "nothing-to-see-here"
    But I should not see "Root"

  Scenario: Create and delete group
    When I follow "Create Group"
    And I fill in "Name" with "le java enterprisers"
    And I check "nothing-to-see-here"
    And I press "Create"
    Then I should be on the groups page
    And I should see "le java enterprisers"
    And I should see "nothing-to-see-here"
    When I follow "Delete"
    And confirm the dialog
    Then I should see "Group deleted"
