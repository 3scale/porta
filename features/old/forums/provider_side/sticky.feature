@saas-only
Feature: Sticky Topics
  In order to let a topic stay on top of other topics so it is surely noticed by the users
  As a provider
  I want to mark it as sticky

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "forum" enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"

  Scenario: Creating a sticky topic
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

    And I go to the provider side new topic page
    And I fill in "Title" with "Read this first"
    And I fill in "Body" with "Make sure you read this first"
    And I check "Sticky"
    And I press "Create thread"
    Then the forum of "foo.3scale.localhost" should have sticky topic "Read this first"

    When I log out
    And I log in as "bob" on "foo.3scale.localhost"
    And I create a new topic "Please help!"
    And I create a new topic "Please help again!"
    And I go to the forum page
    Then I should see the first topic is "Read this first"

  Scenario: Marking existing topic as sticky
    Given the forum of "foo.3scale.localhost" has the following topics:
      | Topic        | Created at |
      | First topic  | 3 days ago |
      | Second topic | 2 days ago |
      | Third topic  | 1 day ago  |

    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the forum page
    Then I should see the first topic is "Third topic"

    When I log out
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

    And I go to the provider side edit "Second topic" topic page
    And I check "Sticky"
    And I press "Update thread"
    Then the forum of "foo.3scale.localhost" should have sticky topic "Second topic"

    When I log out
    And I log in as "bob" on "foo.3scale.localhost"
    And I go to the forum page
    Then I should see the first topic is "Second topic"

  Scenario: Unsticking a topic
    Given the forum of "foo.3scale.localhost" has the following topics:
      | Topic        | Sticky? | Created at |
      | First topic  | no      | 1 day ago  |
      | Second topic | yes     | 2 days ago |

    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the forum page
    Then I should see the first topic is "Second topic"
    When I log out

    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

    And I go to the provider side edit "Second topic" topic page
    And I uncheck "Sticky"
    And I press "Update thread"
    Then the forum of "foo.3scale.localhost" should have non-sticky topic "Second topic"

    When I log out
    And I log in as "bob" on "foo.3scale.localhost"
    And I go to the forum page
    Then I should see the first topic is "First topic"

  @security
  Scenario: Non-admins can't create sticky topics
    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the new topic page
    Then I should not see field "Sticky"
