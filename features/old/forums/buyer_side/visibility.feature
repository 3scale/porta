@saas-only
Feature: Forum visibility
  In order to have control over the forum
  The forum should be hidden or public
  in the buyer side at will

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And a buyer "buyer" signed up to provider "foo.3scale.localhost"
    And the current domain is foo.3scale.localhost

  Scenario: Buyer cannot access the forum if is disabled
    Given provider "foo.3scale.localhost" has "forum" disabled
    When I log in as "buyer" on "foo.3scale.localhost"
      And I go to the forum page
    Then I should see "Page not found"

  Scenario: Buyer has to be logged to see the subscriptions page
    Given the current domain is "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "forum" enabled
      And I am not logged in
    When I request the url of the forum subscriptions page
      And I should be on the login page
      And I fill in the "buyer" login data
    Then I should be on the forum subscriptions page

  Rule: Forum disabled
    Background:
      Given I have rolling updates "forum" disabled
      And I am not logged in
      And provider "foo.3scale.localhost" has "forum" enabled

    Scenario: Buyer cannot access Forum
      When I request the url of the forum subscriptions page
      Then I should be on the forum subscriptions page
      Then I should see "Page not found"
