Feature: CMS groups
  As a provider I want to be able to manage buyer groups and their permissions

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "groups" switch allowed
      And I am logged in as provider "foo.example.com" on its admin domain
      And provider "foo.example.com" has a private section "nothing-to-see-here"
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

      When I follow "Delete"
      Then I should see "Group deleted"
