@backend
Feature: Buyer's application referrer filters (multiple applications mode)
  In order specify where my application can be used from
  As a buyer
  I want to define referrer filters

  Background:
    Given a provider "foo.example.com"
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And referrer filters are required for the service of provider "foo.example.com"
    And a default application plan of provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" has application "MegaWidget"
    And I don't care about application keys
    And the current domain is foo.example.com

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
    Given the current domain is foo.example.com
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    And I submit the new referrer filter form with "foo.example.org"
    Then I should see referrer filter "foo.example.org"

  @allow-rescue @fakeweb
  Scenario: Create invalid referrer filter
    Given the current domain is foo.example.com
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

  @allow-rescue
  Scenario: Attempt to create more referrer filters than the limit fails
    Given the referrer filter limit for application "MegaWidget" is reached
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    And I do POST to the referrer filters url for application "MegaWidget"
    Then I should see referrer filters limit reached error

  @javascript
  Scenario: Delete referrer filter
    Given the current domain is foo.example.com
    Given application "MegaWidget" has the following referrer filters:
      | foo.example.org |
    #And the backend will delete referrer filter "foo.example.org" for application "MegaWidget"
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    And I press "Delete" for referrer filter "foo.example.org"
    Then I should not see referrer filter "foo.example.org"

  Scenario: Referrer filters are not available if they are not required
    Given referrer filters are not required for the service of provider "foo.example.com"
    When I log in as "bob"
    And I go to the "MegaWidget" application page
    Then I should not see "Referrer Filters"

  @security
  Scenario: Creating referrer filter is forbidden if not logged in
    When I do POST to the referrer filters url for application "MegaWidget"
    Then I should be on the login page

  @security
  Scenario: Deleting referrer filter is forbidden if not logged in
    Given application "MegaWidget" has the following referrer filters:
      | foo.example.org |
    When I do DELETE to the "foo.example.org" referrer filter url for application "MegaWidget"
    Then I should be on the login page

  # FIXME: this scenario fails because it redirects to non existing page after login
  # so i suspect it leaks some cookies from previous one
  @security @allow-rescue
  Scenario: Creating referrer filter is forbidden if not buyer of the application
    Given a buyer "alice" signed up to provider "foo.example.com"
    And buyer "alice" has application "MiniWidget"

    When I log in as "alice"
    And I do POST to the referrer filters url for application "MegaWidget"
    Then I should get 404

  @security @allow-rescue
  Scenario: Deleting referrer filter is forbidden if not buyer of the application
    Given a buyer "alice" signed up to provider "foo.example.com"
    And buyer "alice" has application "MiniWidget"
    Given application "MegaWidget" has the following referrer filters:
      | foo.example.org |

    When I log in as "alice"
    And I do DELETE to the "foo.example.org" referrer filter url for application "MegaWidget"
    Then I should get 404
