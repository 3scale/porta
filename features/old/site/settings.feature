Feature: Site settings
  In order to have control of my site
  As a provider
  I want to have a cool settings management

  Background:
    Given a provider "foo.3scale.localhost"

  @security
  Scenario: Settings is not available for buyers
    Given provider "foo.3scale.localhost" has multiple applications enabled
      And a buyer "bob" signed up to provider "foo.3scale.localhost"
    When I log in as "bob" on "foo.3scale.localhost"
    When I request the url of the "site settings" page then I should see 404
