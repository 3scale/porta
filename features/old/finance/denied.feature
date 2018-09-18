Feature: Provider has finance denied

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "finance" switch denied
      And an application plan "plus" of provider "master"

  Scenario: Display upgrade notice when finance switch is denied
     Given current domain is the admin domain of provider "foo.example.com"
      When I log in as provider "foo.example.com"
      When I follow "Billing" within the main menu
      Then I should see upgrade notice for "finance"
      And I should see the provider menu
