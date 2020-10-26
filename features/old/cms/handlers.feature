Feature: Markdown/Textile Handlers
  In order to simplify writing content
  As a provider
  I want to write markdown/textile format

  Scenario:
    Given a provider "foo.3scale.localhost"
      And I have cms page "/page" of provider "foo.3scale.localhost" with markdown content
      And the current domain is "foo.3scale.localhost"
    When I visit "/page"
    Then I should see rendered markdown content
