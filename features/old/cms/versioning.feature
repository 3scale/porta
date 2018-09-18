Feature: CMS Templates versioning
  As a provider
  I want to see history of my content changes

  Background:
    Given a provider "foo.example.com"
    And I am logged in as provider "foo.example.com" on its admin domain
    And the time flies to 2012-12-24 12:00:00
    And I have cms page "/my-page" of provider "foo.example.com"
    And I go to the CMS Page "/my-page" page

  Scenario: Versioning
    When I fill in "Draft" with "My content"
     And I press "Save as Version" at 13:00:00
     And I press "Save as Version" at 14:00:00
     And I press "Publish" at 15:00:00
     And I press "Publish" at 16:00:00
     And I follow "Versions of this page"
    Then I should see following table:
      | Created On               | Author          | Type of Version |
      | 24 Dec 2012 16:00:00 UTC | foo.example.com | published       |
      | 24 Dec 2012 15:00:00 UTC | foo.example.com | published       |
      | 24 Dec 2012 14:00:00 UTC | foo.example.com | draft           |
      | 24 Dec 2012 13:00:00 UTC | foo.example.com | draft           |
      | 24 Dec 2012 13:00:00 UTC | foo.example.com |                 |
      # a.k.a Xmas special
      When I follow "Show 2012-12-24 16:00:00 UTC"
      Then I should see "Version of Page"
