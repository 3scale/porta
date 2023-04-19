@javascript
Feature: CMS Templates versioning
  As a provider
  I want to see history of my content changes

  Background:
    Given a provider is logged in
    And the time flies to 2012-12-24 12:00:00
    And I have cms page "/my-page" of provider "foo.3scale.localhost"
    And I go to the CMS Page "/my-page" page

  Scenario: Versioning
    When fill the template draft with "My content"
    And save it as version at 13:00:00
    And save it as version at 14:00:00
    And I press "Publish" at 15:00:00
    And I press "Publish" at 16:00:00
    And I follow "Versions of this page"
    Then I should see following table:
      | Created On               | Author               | Type of Version |
      | 24 Dec 2012 16:00:00 UTC | foo.3scale.localhost | published       |
      | 24 Dec 2012 15:00:00 UTC | foo.3scale.localhost | published       |
      | 24 Dec 2012 14:00:00 UTC | foo.3scale.localhost | draft           |
      | 24 Dec 2012 13:00:00 UTC | foo.3scale.localhost | draft           |
      | 24 Dec 2012 13:00:00 UTC | foo.3scale.localhost |                 |
    # a.k.a Xmas special
    When I follow "Show 2012-12-24 16:00:00 UTC"
    Then I should see "Version of Page"
