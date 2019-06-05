@saas-only @javascript
Feature: Forum categories administration
  In order to better organise forum topics
  As a provider
  I want to assign a topic to a category

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has "forum" enabled
    And current domain is the admin domain of provider "foo.example.com"

  Scenario: Create a category
    When I log in as provider "foo.example.com"
    And I go to the provider side forum page
    And I follow "Categories"
    And I follow "New category"
    And I fill in "Name" with "Random stuff"
    And I press "Create category"
    And I should see "Category was successfully created."
    Then I should be on the provider side forum categories page
    And I should see category "Random stuff" in the list
    And the forum of "foo.example.com" should have category "Random stuff"

  Scenario: Edit a category
    Given the forum of "foo.example.com" has category "Random stuff"
    When I log in as provider "foo.example.com"
    And I go to the provider side forum page
    And I follow "Categories"
    And I follow "Edit" for category "Random stuff"
    And I fill in "Name" with "Off topic"
    And I press "Update category"
    Then I should be on the provider side forum categories page
    And I should see "Category was successfully updated."
    And I should see category "Off topic" in the list
    But I should not see category "Random stuff" in the list

  Scenario: Delete a category
    Given the forum of "foo.example.com" has category "Random stuff"
    When I log in as provider "foo.example.com"
    And I go to the provider side forum page
    And I follow "Categories"
    And I press "Delete" for category "Random stuff"
    Then I should be on the provider side forum categories page
    And I should see "Category was successfully deleted."
    And I should not see category "Random stuff" in the list

  # TODO: delete a category with topics
