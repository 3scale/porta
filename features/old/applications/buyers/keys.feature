@fakeweb
Feature: Application Keys
  In order to make the API usage secure
  As a buyer
  I want to generate and manage application keys

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And a default application plan of provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" has application "MegaWidget"

  Scenario: List keys
    When the current domain is foo.example.com
    Given application "MegaWidget" has the following keys:
      | key-one |
      | key-two |

    When I log in as "bob" on foo.example.com
    And I go to the "MegaWidget" application page
    Then I should see application key "key-one"
    And I should see application key "key-two"

  Scenario: Create key
    Given application "MegaWidget" has no keys
    When the current domain is foo.example.com
    When I log in as "bob" on foo.example.com
    And I go to the "MegaWidget" application page
    Given the backend will create key "key-one" for application "MegaWidget"
    When I press "Create new key"
    Then I should see application key "key-one"

  Scenario: Create new key button is hidden when key limit is reached
    When the current domain is foo.example.com
    Given the key limit for application "MegaWidget" is reached
    When I log in as "bob" on foo.example.com
    And I go to the "MegaWidget" application page
    Then I should see "At most "

  @wip @allow-rescue
  Scenario: Attempt to create more keys than the limit fails
    When the current domain is foo.example.com
    Given the key limit for application "MegaWidget" is reached
    When I log in as "bob" on foo.example.com
    And I go to the "MegaWidget" application page
    And I do POST to the keys url for application "MegaWidget"
    Then I should see application keys limit reached error

  Scenario: Delete Key with mandatory one key
    When the current domain is foo.example.com
    Given application "MegaWidget" has the following keys:
      | key-one |
    And the backend will delete key "key-one" for application "MegaWidget"
    And the service of provider "foo.example.com" has "mandatory_app_key" set to "true"

    When I log in as "bob" on foo.example.com
    And I go to the "MegaWidget" application page
    Then the key "key-one" should not be deleteable

  Scenario: Delete key without mandatory one key
    When the current domain is foo.example.com
    Given application "MegaWidget" has the following keys:
      | key-one |
    And the backend will delete key "key-one" for application "MegaWidget"
    And the service of provider "foo.example.com" has "mandatory_app_key" set to "false"

    When I log in as "bob" on foo.example.com
    And I go to the "MegaWidget" application page
    And I press "Delete" for application key "key-one"
    Then I should see "Application key was deleted."
