@search @no-txn @saas-only
Feature: Forum searching
  In order to find stuff in the forum
  As an user
  I want to search it

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "forum" enabled
    And a buyer "bob" signed up to provider "foo.example.com"

  Scenario: Search by topic title
    Given the forum of "foo.example.com" has topics "Security", "Hacking" and "Off topic"
    And the Sphinx indexes are updated

    When I log in as "bob" on foo.example.com
    And I go to the forum page
    Then I should see topics "Security", "Hacking" and "Off topic"

    When I search for "security"
    Then I should see topic "Security"
    But I should not see topics "Hacking" and "Off topic"
  
  Scenario: Search by substring of topic title
    Given the forum of "foo.example.com" has topics "Security" and "Hacking"
    And the Sphinx indexes are updated

    When I log in as "bob" on foo.example.com
    And I go to the forum page
    When I search for "sec"
    Then I should see topic "Security"

  Scenario: Search by posts content
    Given the forum of "foo.example.com" has topics "Security" and "Hacking"
    And a post "Some security things" under topic "Security"
    And a post "How to hack stuff" under topic "Hacking"
    And the Sphinx indexes are updated

    When I log in as "bob" on foo.example.com
    And I go to the forum page
    And I search for "stuff"
    Then I should see topic "Hacking"
    But I should not see topic "Security"

  Scenario: Recently created topic is searchable
    When I log in as "bob" on foo.example.com
    And I create a new topic "Hacking"
    And the Sphinx indexes are updated
    And I go to the forum page
    And I search for "hacking"
    Then I should see topic "Hacking"
  
  Scenario: Recently created post is searchable
    Given the forum of "foo.example.com" has topic "Hacking"

    When I log in as "bob" on foo.example.com
    And I reply to topic "Hacking" with "That makes no sense at all"

    And the Sphinx indexes are updated
    And I go to the forum page
    And I search for "sense"
    Then I should see topic "Hacking"
  
  @allow-rescue
  Scenario: Friendly error message when search server is down
    Given Sphinx is offline
    When I log in as "bob" on foo.example.com
    And I go to the forum page
    And I search for "plutonium"
    Then I should see "Search is temporarily offline. Please try again in few minutes."

