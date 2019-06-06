@javascript
Feature: Bulk operations
  In order to approve or reject accounts quickly
  As a provider
  I want to change account states in bulk

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "service_plans" visible
      And a default service of provider "foo.example.com" has name "Fancy API"
      And a service "New Service" of provider "foo.example.com"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.example.com":
      | name | plans              | state     |
      | bob  | Basic, Unpublished | pending   |
      | jane | Basic              | live      |
      | mike | Unpublished        | suspended |
    Given current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"

  Scenario: Accept subscription
      And I am on the service contracts admin page

    When I follow "Account" within table
     And I check select for "bob" and "mike"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected subscriptions"

    When I select "Accept" from "Action" and I confirm dialog box
     And I press "Change state" within fancybox

    Then I should see "Action completed successfully"

    # there is no transision suspended => live
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

    When I select "Suspend" from "Action" and I confirm dialog box
     And I press "Change state" within fancybox

    Then I should see "Action completed successfully"

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

    When I select "Resume" from "Action" and I confirm dialog box
     And I press "Change state" within fancybox

    Then I should see "Action completed successfully"

    # resume = suspended => live
    Then I should see following table:
      | Account ▲ | State   |
      | bob       | pending |
      | bob       | pending |
      | jane      | live    |
      | mike      | live    |

