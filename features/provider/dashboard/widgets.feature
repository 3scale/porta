@javascript
Feature: Dashboard Widgets
  In order to navigate easily to products and backends

  Background:
    Given a provider

  Rule: admin logs in
    Background:
      And the provider logs in

    Scenario: Find products and backends quickly
      Given 10 products and 10 backend apis
      When they go to the provider dashboard
      Then the most recently updated products and backends can be found in the dashboard

    Scenario: Provider can't create new products, only backends
      Given the provider has the following setting:
        | can create service | false |
      And the provider has "multiple_services" switch denied
      When they go to the provider dashboard
      Then there should not be a link to "Create Product" within the products widget
      And there should be a link to "Create Backend" within the backends widget

    Scenario: Add new products and backends quickly
      Given the provider has the following setting:
        | can create service | true |
      And the provider has "multiple_services" switch allowed
      When they go to the provider dashboard
      Then there should be a link to "Create Product" within the products widget
      And there should be a link to "Create Backend" within the backends widget

  Rule: member logs in
    Background:
      Given a member user "Dude" of the provider
      And the user logs in

    Scenario: User with no permissions doesn't see widgets
      Given the user has no permissions
      When they go to the provider dashboard
      Then they should see "Access permissions needed"
      And there should be a link to "contact foo.3scale.localhost"
      But they should not be able to see the products widget
      And they should not be able to see the backends widget

    Scenario: User with partner permission sees products
      Given the user has partners permission
      When they go to the provider dashboard
      Then they should not see "Access permissions needed"
      And they should be able to see the products widget
      And they should not be able to see the backends widget

    Scenario: User with monitoring permission sees both widgets
      Given the user has monitoring permission
      When they go to the provider dashboard
      Then they should not see "Access permissions needed"
      And they should be able to see the products widget
      And they should be able to see the backends widget

    Scenario: User with plans permission sees both widgets
      Given the user has plans permission
      When they go to the provider dashboard
      Then they should not see "Access permissions needed"
      And they should be able to see the products widget
      And they should be able to see the backends widget

    Scenario: User with policy registry permission sees products
      Given the user has policy_registry permission
      When they go to the provider dashboard
      Then they should not see "Access permissions needed"
      And they should be able to see the products widget
      And they should not be able to see the backends widget
