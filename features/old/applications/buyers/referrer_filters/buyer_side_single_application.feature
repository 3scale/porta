@wip
Feature: Buyer's application referrer filters (single application mode)
  In order specify where my application can be used from
  As a buyer
  I want to define referrer filters

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications disabled
    And referrer filters are required for the service of provider "foo.example.com"
    And an application plan "Default" of provider "foo.example.com"
    And a buyer "bob" signed up to application plan "Default"
    And I don't care about application keys

  Scenario: List referrer filters
    Given the application of buyer "bob" has the following referrer filters:
      | foo.example.org |
      | bar.example.org |

    When I log in as "bob" on foo.example.com
    And I go to the buyer access details page

    Then I should see "Referrer Filters"
    And I should see referrer filter "foo.example.org"
    And I should see referrer filter "bar.example.org"

  @javascript
  Scenario: Create valid referrer filter
    Given the application of buyer "bob" has no referrer filters
    And the backend will create referrer filter "foo.example.org" for the application of buyer "bob"
    When I log in as "bob" on foo.example.com
    And I go to the buyer access details page
    And I submit the new referrer filter form with "foo.example.org"
    Then I should see referrer filter "foo.example.org"

  @javascript @allow-rescue
  Scenario: Create invalid referrer filter
    Given the application of buyer "bob" has no referrer filters
    And the backend will respond with error on attempt to create blank referrer filter for the application of buyer "bob"
    When I log in as "bob" on foo.example.com
    And I go to the buyer access details page
    And I submit the new referrer filter form with ""
    Then I should see referrer filter validation error "referrer filter can't be blank"
  
  @javascript
  Scenario: Delete referrer filter
    Given the application of buyer "bob" has the following referrer filters:
      | foo.example.org |
    And the backend will delete referrer filter "foo.example.org" for the application of buyer "bob"
    When I log in as "bob" on foo.example.com
    And I go to the buyer access details page
    And I press "Delete" for referrer filter "foo.example.org"
    Then I should not see referrer filter "foo.example.org"

  Scenario: Referrer filters are not available if they are not required
    Given referrer filters are not required for the service of provider "foo.example.com"
    When I log in as "bob" on foo.example.com
    And I go to the buyer access details page
    Then I should not see "Referrer Filters"
