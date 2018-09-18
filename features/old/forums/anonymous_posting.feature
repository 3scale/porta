@saas-only
Feature: Anonymous posting
  In order to post naughty stuff and engange in violent flamewars without disclosing my identity
  As an user
  I want to post anonymously

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "forum" enabled
      And a buyer "bob" signed up to provider "foo.example.com"
      And the current domain is foo.example.com

  Scenario: Anonymous posting when logged in
    Given provider "foo.example.com" has "anonymous posts" enabled
    And the forum of "foo.example.com" has topic "Check out this new feature"

    When I log in as "bob" on foo.example.com
    And I go to the "Check out this new feature" topic page
    And I fill in "Body" with "I do not like it"
    And I check "Post anonymously"
    And I press "Post reply"

    Then I should see an anonymous post "I do not like it"
    But I should not see post "I do not like it" by "bob"

   Scenario: Anonymous posting when logged out
    Given provider "foo.example.com" has "anonymous posts" enabled
    And the forum of "foo.example.com" has topic "Check out this new feature"
    And I go to the "Check out this new feature" topic page
    Then I should not see field "Post anonymously"
    When I fill in "Body" with "Bla bla bla"
     And I press "Post reply"
    Then I should see an anonymous post "Bla bla bla"

   Scenario: Anonymous posting new thread when logged out
    Given provider "foo.example.com" has "anonymous posts" enabled
    When I am on the forum page
    Then I follow "Start new thread"
     And I fill in "Title" with "New Thread"
     And I fill in "Body" with "My Body"
    When I press "Create thread"
    Then I should see post "My Body"

  @security @allow-rescue
  Scenario: Anonymous posting is disabled and user is logged out
    Given provider "foo.example.com" has "anonymous posts" disabled
    When I am on the forum page
    Then I should not see the link to create new topic

    When I go to the new topic page
    Then I should be on the login page

  @security @allow-rescue
  Scenario: Can't post anonymously when anonymous posting disabled
    Given provider "foo.example.com" has "anonymous posts" enabled
      And the forum of "foo.example.com" has topic "Check out this new feature"
    When I go to the "Check out this new feature" topic page
    Then I should not see field "Post anonymously"
    When I fill in "Body" with "Hack post"
     And provider "foo.example.com" has "anonymous posts" disabled
     And I press "Post reply"
    Then I should be on the login page
