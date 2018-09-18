Feature: Admin domain
  In order to add convenience and remove confusion
  As a provider
  I want to be able to access admin side on both master domain and my dedicated domain but always end up on the master domain

  Background:
    Given a provider "foo.example.com"

  @wip @3D
  Scenario: Master domain have homepage in connect mode
    Given provider "foo.example.com" has Browser CMS deactivated
      And current domain is the admin domain of provider "foo.example.com"

    When I log in as provider "foo.example.com"
    And I go to the homepage
    Then the current domain should be the master domain
    And I should be on the dashboard

  @wip @3D
  Scenario: Master domain homepage redirects to public homepage in enterprise mode
    Given provider "foo.example.com" has Browser CMS activated
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "foo.example.com"
      And I go to the homepage
    Then the current domain should be foo.example.com
      And I should be on the homepage

  # TODO: Not sure we actually still want this behaviour:
  @wip
  Scenario: On dedicated domain
    When the current domain is foo.example.org
    And I go to the dashboard
    Then the current domain should be the master domain

  @wip
  Scenario: On dedicated domain and non-standard port
    When the current domain is foo.example.org and the port is 1234
    And I go to the dashboard
    Then the current domain should be the master domain
    And the current port should be 1234
