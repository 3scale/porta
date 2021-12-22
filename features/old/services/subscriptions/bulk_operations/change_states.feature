@javascript
Feature: Bulk operations
  In order to approve or reject accounts quickly
  As a provider
  I want to change account states in bulk

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "service_plans" visible
      And a default service of provider "foo.3scale.localhost" has name "Fancy API"
      And a service "New Service" of provider "foo.3scale.localhost"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.3scale.localhost":
      | name | plans              | state     |
      | bob  | Basic, Unpublished | pending   |
      | jane | Basic              | live      |
      | mike | Unpublished        | suspended |
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    Given I am logged in as provider "foo.3scale.localhost"

  Scenario: Do nothing
    And I am on the service contracts admin page
    And I check select for "bob" and "mike"
    And I press "Change state"
    Then I should see "Accept, suspend or resume selected applications"
    And I press "Change state" and I confirm dialog box within fancybox
    Then I should see "Required parameter missing: action"

  Scenario: Accept subscription
      And I am on the service contracts admin page

    When I follow "Account" within table
     And I check select for "bob" and "mike"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected subscriptions"

    When I select "Accept" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    When I go to the service contracts admin page
     And I follow "Account" within table

    # there is no transition suspended => live
    Then I should see following table:
     | Account ▲ | State     |
     | bob       | live      |
     | bob       | live      |
     | jane      | live      |
     | mike      | suspended |

  Scenario: Suspend subscriptions
      And I am on the service contracts admin page

    When I follow "Account" within table
     And I check select for "bob" and "jane"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected subscriptions"

    When I select "Suspend" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    When I go to the service contracts admin page
     And I follow "Account" within table

    # pending cannot be changed to suspended
    Then I should see following table:
      | Account ▲ | State     |
      | bob       | pending   |
      | bob       | pending   |
      | jane      | suspended |
      | mike      | suspended |

  Scenario: Resume applications
      And I am on the service contracts admin page

    When I follow "Account" within table
     And I check select for "bob" and "mike"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected subscriptions"

    When I select "Resume" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    When I go to the service contracts admin page
     And I follow "Account" within table

    # resume = suspended => live
    Then I should see following table:
      | Account ▲ | State   |
      | bob       | pending |
      | bob       | pending |
      | jane      | live    |
      | mike      | live    |
