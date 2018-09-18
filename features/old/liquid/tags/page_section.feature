@wip
Feature: Liquid tags
  In order to have a wonderful liquid experience
  There should be tags available for me to use

  Background:
    Given a provider "foo.example.com"
      And the current domain is foo.example.com
    And I am logged in as "foo.example.com"


  Scenario: Tag page_section works for simple cms
    Given provider "foo.example.com" has Browser CMS deactivated
    And a liquid template "main_layout" of provider "foo.example.com" with content
      """
        simple cms page_section {{ page_section }}
      """
    When I go to the homepage
    Then I should see "simple cms tag page_section home"


  Scenario: Tag page_section works for browser cms
    Given provider "foo.example.com" has Browser CMS activated
    And a liquid template "main_layout" of provider "foo.example.com" with content
      """
        bcms page_section {{ page_section }}
      """
    When I go to the homepage
    Then I should see "bcms tag page_section content"
