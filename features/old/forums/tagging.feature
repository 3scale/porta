@wip @saas-only
Feature: Tags on Forum
  In order to have the forum content categorized
  I want to be able to have tags on it

  Background:
    Given a published plan "Basic" of provider "Master account"
    And plan "Basic" has "Forum" enabled
    And a provider "foo.example.com" signed up to plan "Basic"
    And provider "foo.example.com" has "forum" enabled

  Scenario: Tagging topic
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"
    And I visit the page to create new topic
    Then I should see the page to create new topic

    When I fill in the obligatory topic fields
    And I fill in "Tags" with "tag1 tag2"
    And I press the topic creation submit button

    Then I should see the newly created topic
    And I should see the tags

  Scenario: Forum filtering by tags
    Given the forum of "foo.example.com" have the topics:
         | topic    | tagged with     |
         | debian   | skypekit, linux |
         | hal 9000 | skypekit        |

    When I log in as "foo.example.com" on foo.example.com
    And I go to foo.example.com
    And I visit the forum page with no tag
    Then I should see all the topics on the forum of "foo.example.com"

    When I go to foo.example.com
    And I visit the forum page with tag "linux"
    Then I should see only the debian topic

  @admin_side
  Scenario: Topics have tags listed without links on admin side
    Given the forum of "foo.example.com" have the topics:
       | topic    | tagged with     |
       | linuxian | linux, debian   |
       | skypian  | skypekit, phone |
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"
    And I visit on the admin side the page of the topic "linuxian" on the forum of "foo.example.com"
    Then I should see the tags of the topic

  @public_side
  Scenario: Topics have tags listed with links on public side
    Given the forum of "foo.example.com" have the topics:
       | topic    | tagged with     |
       | linuxian | linux, debian   |
       | skypian  | skypekit, phone |
    When I log in as "foo.example.com" on foo.example.com
    And I visit on the public side the topic "skypian" on the forum of "foo.example.com"
    Then I should see the links to search by its tags
