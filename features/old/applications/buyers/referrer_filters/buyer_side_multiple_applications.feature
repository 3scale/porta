@backend
Feature: Buyer's application referrer filters (multiple applications mode)
  In order specify where my application can be used from
  As a buyer
  I want to define referrer filters

  Background:
    Given a provider "foo.3scale.localhost"
    Given provider "foo.3scale.localhost" uses backend v2 in his default service
    And provider "foo.3scale.localhost" has multiple applications enabled
    And referrer filters are required for the service of provider "foo.3scale.localhost"
    And a default application plan of provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" has application "MegaWidget"
    And I don't care about application keys
    And the current domain is "foo.3scale.localhost"

  Scenario: List referrer filters
    Given application "MegaWidget" has the following referrer filters:
      | foo.example.org |
      | bar.example.org |

    When I log in as "bob"
    And I go to the "MegaWidget" application page

    Then I should see "Referrer Filters"
    And I should see referrer filter "foo.example.org"
    And I should see referrer filter "bar.example.org"

  @javascript
  Scenario: Create valid referrer filter
    Given the current domain is "foo.3scale.localhost"
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    And I submit the new referrer filter form with "foo.example.org"
    Then I should see referrer filter "foo.example.org"

  @allow-rescue
  Scenario: Create invalid referrer filter
    Given the current domain is "foo.3scale.localhost"
    Given application "MegaWidget" has no referrer filters
    And the backend will respond with error on attempt to create blank referrer filter for application "MegaWidget"
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    And I submit the new referrer filter form with ""
    Then I should see the flash message "referrer filter can't be blank"

  @javascript
  Scenario: The add new referrer filter form is hidden when the limit is reached
    Given the referrer filter limit for application "MegaWidget" is reached
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    Then I should see referrer filters limit reached error

  @javascript
  Scenario: Delete referrer filter
    Given the current domain is "foo.3scale.localhost"
    Given application "MegaWidget" has the following referrer filters:
      | foo.example.org |
    #And the backend will delete referrer filter "foo.example.org" for application "MegaWidget"
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    And I press "Delete" for referrer filter "foo.example.org"
    Then I should not see referrer filter "foo.example.org"

  Scenario: Referrer filters are not available if they are not required
    Given referrer filters are not required for the service of provider "foo.3scale.localhost"
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    Then I should not see "Referrer Filters"
