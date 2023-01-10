Feature: Paid plan
  In order to charge my users and get rich
  As a provider
  I want to setup paid plans

  Background:
    Given a published plan "Basic" of provider "Master account"
    And a provider "foo.3scale.localhost" signed up to plan "Basic"
    And an application plan "Foo" of provider "foo.3scale.localhost"

  Scenario: Billing allowed, all postpaid details valid
    Given provider "foo.3scale.localhost" is charging its buyers

    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

    And I go to the edit page for plan "Foo"
    Then I should see "Setup fee"
    And I should see "Cost per month"
