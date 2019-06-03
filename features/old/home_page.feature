Feature: Home page
  In order to get good impression from the site
  As whoever
  There should be kickass home page

  Background:
    Given a provider "foo.example.com"

  Scenario: On buyer side with advanced CMS enabled
  Given there are no pages
    And provider "foo.example.com" has a public page at "/" with content
      """
      This is advanced CMS page
      """

    When the current domain is "foo.example.com"
    And I go to the homepage
    Then I should see "This is advanced CMS page"

  @allow-rescue
  Scenario: Invalid domain
    Given there is no provider with domain "bar.example.com"
    When the current domain is "bar.example.com"
    And I go to the homepage
    Then I should see "Not found"
