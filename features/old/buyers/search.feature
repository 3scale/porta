@search @no-txn
Feature: Search
  In order to search on pages
  Buyer will need to have a search form

  Background:
    Given a provider "foo.3scale.localhost"
    Given provider "foo.3scale.localhost" has a private section "priv" with path "/priv"
      And provider "foo.3scale.localhost" has a public section "pub" with path "/pub"
      And provider "foo.3scale.localhost" has a published page with the title "title foo" and path "/foo" of section "pub"
      And provider "foo.3scale.localhost" has a published page with the title "title bar" and path "/bar" of section "priv"
      And the current domain is "foo.3scale.localhost"
    And a product "My API"
    And the following application plan:
      | Product | Name  |
      | My API  | Basic |
      And a buyer "bob" signed up to application plan "Basic"
      And I go to the search page

  Scenario: No pages match the search
    Given I log in as "bob"
     When I fill in "q" with "poiuyt"
      And I press "Search"
     Then I should see "0 documents matched"

  Scenario: A Page matches. Shows only accessible pages
    Given I log in as "bob"
     When I fill in "q" with "title"
      And I press "Search"
     Then I should see "title foo"
     Then I should not see "title bar"
     Then I should see "1 documents matched"

  Scenario: Show highlight word in pages
    Given I log in as "bob"
    When I fill in "q" with "title"
    And I press "Search"
    Then I should see highlighted "title" in "term"
    And I should see highlighted "title" in "definition"
