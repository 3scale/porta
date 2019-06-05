@saas-only @javascript
Feature: Posting in the forum
  In order to ask question or spread opinions
  As a provider
  I want to post in the forum
  from the comfort of the provider area

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has "forum" enabled
    And current domain is the admin domain of provider "foo.example.com"

  Scenario: Create a topic
    When I log in as provider "foo.example.com"
    And I go to the provider side forum page
    And I follow "New Thread"
    And I fill in "Title" with "What is this?"
    And I fill in "Body" with "I have no idea what is all this about. Can you help me out?"
    And I press "Create thread"
    Then I should see "Thread was successfully created."
    And the forum of "foo.example.com" should have topic "What is this?"
    And I should see "Reply to thread"

    When I fill in "Body" with "Let me explain..."
    And I press "Post reply"
    Then I should see "Let me explain"
