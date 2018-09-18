Feature: Markdown/Textile Handlers
  In order to simplify writing content
  As a provider
  I want to write markdown/textile format

  Scenario:
    Given a provider "foo.example.com"
      And I have cms page "/page" of provider "foo.example.com" with markdown content
      And the current domain is "foo.example.com"
    When I visit "/page"
    Then I should see rendered markdown content
