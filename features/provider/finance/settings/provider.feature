Feature: Billing settings
  In order to have control over the billing settings
  As a provider or master
  I want to edit billing settings

Background:
  Given a provider is logged in
  And the provider has "finance" switch visible
  And the provider is charging

Scenario: Active payment gateway
  And the provider has testing credentials for braintree
  When I go to the finance settings page
  Then I should not see "gateway has been deprecated"

Scenario: Deprecated payment gateway
  Given the provider has a deprecated payment gateway
  When I go to the finance settings page
  Then I should see "gateway has been deprecated"
