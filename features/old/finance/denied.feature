Feature: Provider has finance denied

  Background:
    Given a provider is logged in
      And an application plan "plus" of provider "master"

  Scenario: Hide Billing in menu when finance switch is denied
    Given provider "foo.example.com" has "finance" switch denied
    When I go to the provider dashboard
    Then I should not see "Billing"

  Scenario: Display Billing in menu when finance switch is allowed
    Given provider "foo.example.com" has "finance" switch allowed
    When I go to the provider dashboard
    Then I should see "Billing"
