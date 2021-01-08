@saas-only
Feature: Forum viewing
  In order to read other users posts and participate in the discussion
  As an user
  I want to view the forum

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "forum" enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"

  Scenario: Forum posts are rendered with textile
    Given the forum of "foo.3scale.localhost" has topic "Textile rulez" with "Check out this *awesome bold text*"
    When I log in as "bob" on foo.3scale.localhost
    And I go to the "Textile rulez" topic page
    Then I should see "awesome bold text" in bold


  Scenario: Viewing forum not logged in
    Given the forum of "foo.3scale.localhost" has topic "Hello world"

    When the current domain is "foo.3scale.localhost"
      And I am on the forum page
      And I follow "Hello world"
      Then I should see "Hello world"


  @security
  Scenario: Forum requires login
    Given the forum of "foo.3scale.localhost" has topic "Hello world"
      And the forum of provider "foo.3scale.localhost" is private

    When the current domain is "foo.3scale.localhost"
     And I am not logged in
     And I go to the forum page
    Then I should be on the login page

    When I go to the "Hello world" topic page
    Then I should be on the login page

  @wip
  Scenario: Topics are ordered by date of last post by default
    Given the current domain is "foo.3scale.localhost"
    When I log in as "bob"
    And I go to the forum page
    Then I should see topics listed for "foo.exmpale.com" with "topic c" showing first and "topic a" showing last

  @wip
  Scenario: Topic details
    When I log in as "foo.3scale.localhost" on foo.3scale.localhost
    And I visit the page of the first topic on the forum of "foo.3scale.localhost"
    Then I should see the topic title is the page title
    And I should see post dates in the right date format
