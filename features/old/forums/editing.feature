@saas-only
Feature: Editing forum topics and posts
  In order to change what I've posted
  As a forum user
  I want to edit or delete my topics and posts

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has "forum" enabled
    And a buyer "buyer" signed up to provider "foo.example.com"
    And a buyer "luser" signed up to provider "foo.example.com"

    Given provider "foo.example.com" has the following users:
     | User              | State            |
     | alice             | active           |
     | bob               | active           |

    And the time is 14:00

    And the forum of "foo.example.com" has the following topics:
     | Topic                  | Owner      | Created at |
     | from buyer today       | buyer      | today      |
     | from buyer yesterday   | buyer      | yesterday  |
     | from bob               | bob        | 5 days ago |

    And the current domain is foo.example.com

  Scenario: User can edit his topics the first day
    When I log in as "buyer"
    And I go to the "from buyer today" topic page
    And I follow "Edit topic"
    And I fill in "Title" with "from buyer now"
    And I press "Update thread"
    Then I should see "Thread was successfully updated."
    And I should see "from buyer now" in a header
    But I should not see "from buyer today" in a header

  @allow-rescue
  Scenario: User can't edit his topics after the first day
    When I log in as "buyer"
    And I go to the "from buyer yesterday" topic page
    Then I should not see link "Edit topic"

    When I do a HTTP request to update topic "from buyer yesterday"
    Then I should be denied the access

  @security @allow-rescue
  Scenario: User can't edit other users topics
    When I log in as "buyer"
    And I go to the "from bob" topic page
    Then I should not see link "Edit topic"

    When I do a HTTP request to update topic "from bob"
    Then I should be denied the access

  Scenario: User can delete his topics the first day
    When I log in as "buyer"
    And I go to the "from buyer today" topic page
    And I press "Delete"
    Then I should see "Thread was successfully deleted."
    And I should not see topic "from buyer today"

  @allow-rescue
  Scenario: User can't delete his topics after the first day
    When I log in as "buyer"
    And I go to the "from buyer yesterday" topic page
    Then I should not see button "Delete"

    When I do a HTTP request to delete topic "from buyer yesterday"
    Then I should be denied the access

  @security @allow-rescue
  Scenario: User can't delete other users topics
    When I log in as "buyer"
    And I go to the "from bob" topic page
    Then I should not see button "Delete"

    When I do a HTTP request to delete topic "from bob"
    Then I should be denied the access

  Scenario: User can edit his post the first day
    Given user "buyer" posted "Hello world" today under topic "from buyer today"
    When I log in as "buyer"
    And I go to the "from buyer today" topic page
    And I follow "Edit" for post "Hello world"
    And I fill in "Body" with "Hello everyone!"
    And I press "Update Post"
    Then I should see "Post was successfully updated."
    And I should see post "Hello everyone!"
    But I should not see post "Hello world"

  @allow-rescue
  Scenario: User can't edit his post after the first day
    Given user "buyer" posted "Hello world" yesterday under topic "from buyer yesterday"
    When I log in as "buyer"
    And I go to the "from buyer yesterday" topic page
    Then I should not see link "Edit" for post "Hello world"

    When I do a HTTP request to update post "Hello world"
    Then I should be denied the access

  @security @allow-rescue
  Scenario: User can't edit other users posts
    Given user "buyer" posted "Hello world" today under topic "from buyer today"
    When I log in as "luser"
    And I go to the "from buyer today" topic page
    Then I should not see link "Edit" for post "Hello world"

    When I do a HTTP request to update post "Hello world"
    Then I should be denied the access

  Scenario: User can delete his post the first day
    Given user "buyer" posted "Hello world" today under topic "from buyer today"
    When I log in as "buyer"
    And I go to the "from buyer today" topic page
    And I press "Delete" for post "Hello world"
    Then I should see "Post was successfully deleted."
    But I should not see post "Hello world"

  @allow-rescue
  Scenario: User can't delete his post after the first day
    Given user "buyer" posted "Hello world" yesterday under topic "from buyer yesterday"
    When I log in as "buyer"
    And I go to the "from buyer yesterday" topic page
    Then I should not see button "Edit" for post "Hello world"

    When I do a HTTP request to delete post "Hello world"
    Then I should be denied the access

  @security @allow-rescue
  Scenario: User can't delete other users posts
    Given user "buyer" posted "Hello world" today under topic "from buyer today"
    When I log in as "luser"
    And I go to the "from buyer today" topic page
    Then I should not see button "Delete" for post "Hello world"

    When I do a HTTP request to delete post "Hello world"
    Then I should be denied the access

  Scenario: User can't delete a post if it's the last one in the topic
    Given topic "from buyer today" has only one post
    When I log in as "buyer"
    And I go to the "from buyer today" topic page
    Then I should not see button "Delete" for the last post under topic "from buyer today"

  Scenario: User can delete a post if there are more than one in the topic
    Given topic "from buyer today" has 2 posts
    When I log in as "buyer"
    And I go to the "from buyer today" topic page
    And I press "Delete" for the last post under topic "from buyer today"
    Then topic "from buyer today" should have 1 post
