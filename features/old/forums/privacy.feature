@saas-only
Feature: Forum privacy
  In order to have control of the forum
  As a provider I want to be able
  To make it public or private

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "forum" enabled
    And the current domain is foo.3scale.localhost

  Rule: Forum is enabled
    Background:
      And I have rolling updates "forum" enabled

    Scenario: Private forum requires logged in user
      Given the forum of provider "foo.3scale.localhost" is private
      When I am not logged in
      And I go to the forum page
      Then I should be on the login page

    Scenario: Public forum does not require a logged in user
      Given the forum of provider "foo.3scale.localhost" is public
      When I am not logged in
      And I go to the forum page
      Then I should be on the forum page

  Rule: Forum is disabled
    Background:
      And I have rolling updates "forum" disabled

    Scenario: Private forum is hidden
      Given the forum of provider "foo.3scale.localhost" is private
      When I am not logged in
      Then I should not see forum

    Scenario: Public forum is hidden
      Given the forum of provider "foo.3scale.localhost" is public
      When I am not logged in
      Then I should not see forum
