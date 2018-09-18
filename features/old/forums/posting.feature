@saas-only
Feature: Posting in the forum
  In order to ask question or spread opinions
  As a buyer
  I want to post in the forum

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "forum" enabled
    And a buyer "alice" signed up to provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"

  @recaptcha
  Scenario: New topic
    Given provider "foo.example.com" has "spam protection level" set to "auto"
    When I log in as "alice" on foo.example.com
    And I go to the forum page

    And I follow "Start new thread"
    And I fill in "Title" with "What is this?"
    And I fill in "Body" with "I have no idea what is all this about. Can you help me out?"
    And I press "Create thread"
    Then I should see "Thread was successfully created."
    And I should see "What is this?" in a header
    And I should see post "I have no idea what is all this about. Can you help me out?"

  @recaptcha
  Scenario: Reply to a topic
    Given the forum of "foo.example.com" has topic "How to get rich using this API?" from user "alice"
      And provider "foo.example.com" has "spam protection level" set to "captcha"
    When I log in as "bob" on foo.example.com
    And I go to the forum page
    And I follow "How to get rich using this API?"
    And I fill in "Body" with "Just pass get-rich=true param in"
    And I press "Post reply"
    Then I should see "Post was successfully created."
    And I should see post "Just pass get-rich=true param in"

  @wip
  Scenario: New topic fails validation
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

    And I visit the page to create new topic
    Then I should see the page to create new topic

    When I leave the obligatory topic fields blank
    And I press the topic creation submit button
    Then I should see "2 errors prohibited this topic from being saved"

