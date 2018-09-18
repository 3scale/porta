@saas-only
Feature: Forum privacy
  In order to have control of the forum
  As a provider I want to be able
  To make it public or private

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has "forum" enabled
    And the current domain is foo.example.com

  Scenario: Private forum requires logged in user
    Given the forum of provider "foo.example.com" is private
    When I am not logged in
      And I go to the forum page
    Then I should be on the login page

  Scenario: Public forum does not require a logged in user
    Given the forum of provider "foo.example.com" is public
    When I am not logged in
      And I go to the forum page
    Then I should be on the forum page
