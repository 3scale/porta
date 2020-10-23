Feature: Application Keys
  In order to make the API usage secure
  As a buyer
  I want to generate and manage application keys

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" uses backend v2 in his default service
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a default application plan of provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" has application "MegaWidget"

  Scenario: List keys
    When the current domain is "foo.3scale.localhost"
    Given application "MegaWidget" has the following keys:
      | key-one |
      | key-two |

    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the "MegaWidget" application page
    Then I should see application key "key-one"
    And I should see application key "key-two"

  Scenario: Create key
    Given application "MegaWidget" has no keys
    When the current domain is "foo.3scale.localhost"
    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the "MegaWidget" application page
    Given the backend will create key "key-one" for application "MegaWidget"
    When I press "Create new key"
    Then I should see application key "key-one"

  Scenario: Create new key button is hidden when key limit is reached
    When the current domain is "foo.3scale.localhost"
    Given the key limit for application "MegaWidget" is reached
    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the "MegaWidget" application page
    Then I should see "At most "

  @wip @allow-rescue
  Scenario: Attempt to create more keys than the limit fails
    When the current domain is "foo.3scale.localhost"
    Given the key limit for application "MegaWidget" is reached
    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the "MegaWidget" application page
    And I do POST to the keys url for application "MegaWidget"
    Then I should see application keys limit reached error

  Scenario: Delete Key with mandatory one key
    When the current domain is "foo.3scale.localhost"
    Given application "MegaWidget" has the following keys:
      | key-one |
    And the backend will delete key "key-one" for application "MegaWidget"
    And the service of provider "foo.3scale.localhost" has "mandatory_app_key" set to "true"

    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the "MegaWidget" application page
    Then the key "key-one" should not be deleteable

  Scenario: Delete key without mandatory one key
    When the current domain is "foo.3scale.localhost"
    Given application "MegaWidget" has the following keys:
      | key-one |
    And the backend will delete key "key-one" for application "MegaWidget"
    And the service of provider "foo.3scale.localhost" has "mandatory_app_key" set to "false"

    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the "MegaWidget" application page
    And I press "Delete" for application key "key-one"
    Then I should see "Application key was deleted."
