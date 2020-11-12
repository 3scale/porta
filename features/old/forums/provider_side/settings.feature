# these scenarios are marked @wip as they fail often due to "timeout"
@wip @saas-only
Feature: Forum toggle
  In order to decide whether I want the forum module to be enabled/disabled or available only to logged in users
  As a provider
  I want to configure it

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "alice" signed up to provider "foo.3scale.localhost"

  @javascript @wip
  Scenario: Enable the forum
    Given provider "foo.3scale.localhost" has "forum" disabled

    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

    And I go to the forum settings page
    And I check "enabled" for the "Forum" module
    And I press "Update Settings"
    And I log out

    When I log in as "alice" on "foo.3scale.localhost"
    Then I should see the link "Forum"

  @javascript @wip
  Scenario: Disable the forum
    Given provider "foo.3scale.localhost" has "forum" enabled

    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

    And I go to the forum settings page
    And I uncheck "enabled" for the "Forum" module
    And I press "Update Settings"
    And I log out

    When I log in as "alice" on "foo.3scale.localhost"
    Then I should not see link "Forum"

  @javascript @wip
  Scenario: Make the forum public
    Given provider "foo.3scale.localhost" has "forum" enabled and private
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And I go to the forum settings page
    And I check "public" for the "Forum" module
    And I press "Update Settings"

    And I log out
    And the current domain is "foo.3scale.localhost"
    And I go to the forum page
    Then I should be on the forum page

  @javascript @wip
  Scenario: Make the forum private
    Given provider "foo.3scale.localhost" has "forum" enabled and public
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And I go to the forum settings page
    And I uncheck "public" for the "Forum" module
    And I press "Update Settings"

    And I log out
    And the current domain is "foo.3scale.localhost"
    And I go to the forum page
    Then I should be on the login page
