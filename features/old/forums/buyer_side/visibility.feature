@saas-only
Feature: Forum visibility
  In order to have control over the forum
  The forum should be hidden or public
  in the buyer side at will

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And a buyer "buyer" signed up to provider "foo.example.com"
    And the current domain is foo.example.com

  Scenario: Buyer cannot access the forum if is disabled
    Given provider "foo.example.com" has "forum" disabled
    When I log in as "buyer" on "foo.example.com"
      And I go to the forum page
    Then I should see "Forum not found"

  Scenario: Buyer has to be logged to see the subscriptions page
    Given the current domain is "foo.example.com"
      And provider "foo.example.com" has "forum" enabled
      And I am not logged in
    When I request the url of the forum subscriptions page
      And I should be on the login page
      And I fill in the "buyer" login data
    Then I should be on the forum subscriptions page
