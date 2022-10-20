Feature: Asset host
  In order to reduce the network traffic from the web server
  As master, provider or developer
  I want to load all assets from the configured CDN

  Background:
    Given a provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"

  @javascript
  Scenario: Asset host not configured
    When I am logged in as master admin on master domain
    Then assets shouldn't be loaded from the asset host

  @javascript
  Scenario: Master dashboard with asset host configured
    When the asset host is set to "cdn.3scale.localhost"
    And I am logged in as master admin on master domain
    Then assets should be loaded from the asset host

  @javascript
  Scenario: Provider dashboard with asset host configured
    When the asset host is set to "cdn.3scale.localhost"
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"
    Then assets should be loaded from the asset host

  @javascript
  Scenario: Developer portal with asset host configured
    When the asset host is set to "cdn.3scale.localhost"
    Given I log in as "bob" on foo.3scale.localhost
    Then javascript assets should be loaded from the asset host
