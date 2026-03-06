@javascript
Feature: CMS Portlets
  As a provider
  I want to manage CMS data objects

  Background:
    Given a provider is logged in
    And I go to the CMS page
    And wait a moment

  Scenario: Portlet
    When they select "New Portlet" from the CMS new content dropdown
    When I follow "External RSS Feed"
    When I fill in the following:
      | Title       | Patatas Bravas                  |
      | System name | potato_portlet                  |
      | Url feed    | http://news.ycombinator.com/rss |
    And I press "Create External RSS Feed"
    Then I should see "Template created"
    When I fill in the following:
      | System name | brand-new-potato |
    And I press "Save"
    Then I should see "Template saved"
    When I press "Publish"
    Then I should see "Template saved and published"
