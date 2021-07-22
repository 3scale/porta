@saas-only
Feature: Posting in the forum
  In order to ask question or spread opinions
  As a buyer
  I want to post in the forum

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "forum" enabled
    And a buyer "alice" signed up to provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"

  Scenario: New topic
    When I log in as "alice" on foo.3scale.localhost
    And I go to the forum page

    And I follow "Start new thread"
    And I fill in "Title" with "What is this?"
    And I fill in "Body" with "I have no idea what is all this about. Can you help me out?"
    And I press "Create thread"
    Then I should see "Thread was successfully created."
    And I should see "What is this?" in a header
    And I should see post "I have no idea what is all this about. Can you help me out?"

  Scenario: Reply to a topic
    Given the forum of "foo.3scale.localhost" has topic "How to get rich using this API?" from user "alice"
    When I log in as "bob" on foo.3scale.localhost
    And I go to the forum page
    And I follow "How to get rich using this API?"
    And I fill in "Body" with "Just pass get-rich=true param in"
    And I press "Post reply"
    Then I should see "Post was successfully created."
    And I should see post "Just pass get-rich=true param in"

  @wip
  Scenario: New topic fails validation
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

    And I visit the page to create new topic
    Then I should see the page to create new topic

    When I leave the obligatory topic fields blank
    And I press the topic creation submit button
    Then I should see "2 errors prohibited this topic from being saved"

