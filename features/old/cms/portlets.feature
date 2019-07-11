@javascript
Feature: CMS Portlets
  As a provider
  I want to manage CMS data objects

  Background:
    Given a provider "foo.example.com"
    And I am logged in as provider "foo.example.com" on its admin domain
    And I go to the CMS page

  Scenario: Portlet
      When I follow "New Portlet" from the CMS dropdown
      When I follow "External RSS Feed"
      When I fill in the following:
        | Title       | Patatas Bravas                  |
        | System name | potato_portlet                  |
        | Url feed    | http://news.ycombinator.com/rss |
      And I press "Create External RSS Feed"
      Then I should see "External RSS Feed created."

      When I fill in the following:
       | System name | brand-new-potato |
     And I press "Save"
    Then I should see "External RSS Feed saved."

    When I press "Publish"
    Then I should see "External RSS Feed saved and published"
