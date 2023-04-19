@audit @javascript
Feature: Accessing Destroys
  I want to be find deleted stuff in trash

  Background:
    Given a provider is logged in
    And a default application plan "Hammer Time" of provider "foo.3scale.localhost"
    And a published account plan "Hammer Time" of provider "foo.3scale.localhost"

  Scenario: Deleted account is found in trash
    When provider "foo.3scale.localhost" has deleted the buyer "Nicolas Von Kline Wurst"
    And I go to the "accounts" destroys page
    Then I should see "Nicolas Von Kline Wurst" in the list of deleted "accounts"

  Scenario: Deleted application and users are found in trash
    When a buyer "Mc Hammer" signed up to account plan "Hammer Time"
    And buyer "Mc Hammer" has application "ESTOP"
    And provider "foo.3scale.localhost" deleted existing buyer "Mc Hammer"
    And I go to the "apps" destroys page
    Then I should see "ESTOP" in the list of deleted "applications"
    And I go to the "users" destroys page
    Then I should see "Mc_Hammer" in the list of deleted "users"
