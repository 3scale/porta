Feature: Site settings
  In order to have control of my site
  As a provider
  I want to have a cool settings management

  Background:
    Given a provider "foo.example.com"

  @security
  Scenario: Settings is not available for buyers
    Given provider "foo.example.com" has multiple applications enabled
      And a buyer "bob" signed up to provider "foo.example.com"
    When I log in as "bob" on foo.example.com
    When I request the url of the "site settings" page then I should see 404
