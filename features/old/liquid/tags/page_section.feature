@wip
Feature: Liquid tags
  In order to have a wonderful liquid experience
  There should be tags available for me to use

  Background:
    Given a provider "foo.3scale.localhost"
      And the current domain is "foo.3scale.localhost"
    And I am logged in as "foo.3scale.localhost"


  Scenario: Tag page_section works for simple cms
    Given provider "foo.3scale.localhost" has Browser CMS deactivated
    And a liquid template "main_layout" of provider "foo.3scale.localhost" with content
      """
        simple cms page_section {{ page_section }}
      """
    When I go to the homepage
    Then I should see "simple cms tag page_section home"


  Scenario: Tag page_section works for browser cms
    Given provider "foo.3scale.localhost" has Browser CMS activated
    And a liquid template "main_layout" of provider "foo.3scale.localhost" with content
      """
        bcms page_section {{ page_section }}
      """
    When I go to the homepage
    Then I should see "bcms tag page_section content"
