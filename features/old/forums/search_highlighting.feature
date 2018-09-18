@search @no-txn @saas-only
Feature: Search
  In order to search on pages
  Buyer will need to have a search form

  Background:
    Given a provider "foo.example.com"
      And the current domain is "foo.example.com"
      And an application plan "Basic" of provider "foo.example.com"
      And a buyer "bob" signed up to application plan "Basic"
      And the Sphinx indexes are updated
      And I go to the search page

  Scenario: Show highlighted word in forums
    Given the forum of "foo.example.com" has topics "Security stuff"
    And the Sphinx indexes are updated
    And I log in as "bob"
    When I fill in "q" with "stuff"
    And I press "Search"
    Then I should see highlighted "stuff" in "term"
    And I should see highlighted "stuff" in "definition"

  Scenario: Escape html tags
    Given the forum of "foo.example.com" has topics "p> <strong> blablabla <strong>  </p>"
    And the Sphinx indexes are updated
    And I log in as "bob"
    When I fill in "q" with "blablabla"
    And I press "Search"
    Then I should see "p> blablabla"
