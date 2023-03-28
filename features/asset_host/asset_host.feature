@javascript
Feature: Asset host
  In order to reduce the network traffic from the web server
  As master, provider or developer
  I want to load all assets from the configured CDN

  Rule: Master
    Background:
      Given master is the provider

    Scenario: Asset host not configured
      When master admin is logged in
      Then assets shouldn't be loaded from the asset host

    Scenario: Master dashboard with asset host configured
      When the asset host is set to "cdn.3scale.localhost"
      When master admin is logged in
      Then assets should be loaded from the asset host

  Rule: Provider
    Background:
      Given the asset host is set to "cdn.3scale.localhost"
      And a provider is logged in
      And the provider has one buyer

    Scenario: Provider dashboard with asset host configured
      Then assets should be loaded from the asset host

    Scenario: Developer portal with asset host configured
      When the buyer logs in to the provider
      Then javascript assets should be loaded from the asset host
