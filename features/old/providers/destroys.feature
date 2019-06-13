@audit
Feature: Accessing Destroys
  I want to be find deleted stuff in trash

  Background:
    Given a provider "foo.example.com"
    And a default application plan "Hammer Time" of provider "foo.example.com"
    And a published account plan "Hammer Time" of provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"

  Scenario: Deleted account is found in trash
    When provider "foo.example.com" has deleted the buyer "Nicolas Von Kline Wurst"
      And I log in as provider "foo.example.com"
      And I go to the "accounts" destroys page
    Then I should see "Nicolas Von Kline Wurst" in the list of deleted "accounts"

  Scenario: Deleted application and users are found in trash
    When a buyer "Mc Hammer" signed up to account plan "Hammer Time"
      And buyer "Mc Hammer" has application "ESTOP"
      And provider "foo.example.com" deleted existing buyer "Mc Hammer"

    When I log in as provider "foo.example.com"
      And I go to the "apps" destroys page
      Then I should see "ESTOP" in the list of deleted "applications"

      And I go to the "users" destroys page
      Then I should see "Mc_Hammer" in the list of deleted "users"
