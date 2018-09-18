@saas-only
Feature: Forum categories
  In order to have the forum topics nicely organized
  As a forum user
  I want to view the topics by category

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "forum" enabled
    And a buyer "alice" signed up to provider "foo.example.com"

  Scenario: View topics by category
    Given the forum of "foo.example.com" has categories "On topic" and "Off topic"
    And the forum of "foo.example.com" has the following topics:
      | Topic                                      | Category  |
      | Authentication does not work - please help | On topic  |
      | OMG LOL check out this funny video!        | Off topic |

    When I log in as "alice" on foo.example.com
    And I go to the forum page
    And I follow "View by category"
    And I follow "On topic"
    Then I should see topic "Authentication does not work - please help"
    But I should not see topic "OMG LOL check out this funny video!"
    When I follow "View by category"
    And I follow "Off topic"
    Then I should see topic "OMG LOL check out this funny video!"
    But I should not see topic "Authentication does not work - please help"

  Scenario: Post a topic in a category
    Given the forum of "foo.example.com" has categories "Security" and "Howtos"

    When I log in as "alice" on foo.example.com
    And I go to the forum page
    And I follow "Start new thread"
    And I fill in "Title" with "How secure is this thing?"
    And I fill in "Body" with "Really, how secure is it?"
    And I select "Security" from "Category"
    And I press "Create thread"
    Then the forum of "foo.example.com" should have topic "How secure is this thing?" in category "Security"

    When I go to the forum page
    When I follow "View by category"
    And I follow "Security"
    Then I should see topic "How secure is this thing?"

  Scenario: Post a topic when there are no categories
    Given the forum of "foo.example.com" has no categories
    When I log in as "alice" on foo.example.com
    And I go to the new topic page
    Then I should not see field "Category"

  Scenario: Post topic from a category page presets the category
    Given the forum of "foo.example.com" has categories "Security" and "Insecurity"
    And the forum of "foo.example.com" has topic "Hacks" in category "Security"

    When I log in as "alice" on foo.example.com
    And I go to the forum page
    And I follow "View by category"
    And I follow "Security"
    And I follow "Start new thread"
    Then the "Category" select should have "Security" selected


  Scenario: "User can't see manage buttons of categories"
    When I log in as "alice" on foo.example.com
    And the forum of "foo.example.com" has category "category 1"
    And I go to the forum page
    When I follow "View by category"
    Then I should not see link "New category"
    And I should not see link "Edit"
    And I should not see button "Delete"



  @security @allow-rescue
  Scenario: User can't create new category
    When I log in as "alice" on foo.example.com
    And I go to the forum page
    Then I should not see button "New category"
    When I do a HTTP request to create new category "Fake"
    Then I should get 404
    And the forum of "foo.example.com" should not have category "Fake"

  @security @allow-rescue
  Scenario: User can't edit a category
    Given the forum of "foo.example.com" has category "Security"

    When I log in as "alice" on foo.example.com
    And I go to the forum page
    Then I should not see link "Edit" for category "Security"

    When I do a HTTP request to update category "Security"
    Then I should get 404

  @security @allow-rescue
  Scenario: User can't delete a category
    Given the forum of "foo.example.com" has category "Security"

    When I log in as "alice" on foo.example.com
    And I go to the forum page
    Then I should not see button "Delete" for category "Security"

    When I do a HTTP request to delete category "Security"
    Then I should get 404
