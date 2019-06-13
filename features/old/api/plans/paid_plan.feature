Feature: Paid plan
  In order to charge my users and get rich
  As a provider
  I want to setup paid plans

  Background:
    Given a published plan "Basic" of provider "Master account"
    And a provider "foo.example.com" signed up to plan "Basic"
    And an application plan "Foo" of provider "foo.example.com"

  Scenario: Billing allowed, all postpaid details valid
    Given provider "foo.example.com" has billing enabled
    And provider "foo.example.com" has valid payment gateway

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    And I go to the edit page for plan "Foo"
    Then I should see "Setup fee"
    And I should see "Cost per month"
