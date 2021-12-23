@javascript
Feature: Bulk operations
  In order to approve or reject accounts quickly
  As a provider
  I want to change account states in bulk

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled

    Given a default application plan "Bronze" of provider "foo.3scale.localhost"
      And a buyer "Bob" signed up to provider "foo.3scale.localhost"
      And buyer "Bob" has the following applications:
      | name       | state   |
      | PendingApp | pending |
      | LiveApp    | live    |
      | SuspendedApp | suspended |

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I don't care about application keys

  Scenario: Do nothing
    Given I am logged in as provider "foo.3scale.localhost"
    And I am on the applications admin page
    And I check select for "PendingApp" and "SuspendedApp"
    And I press "Change state"
    Then I should see "Accept, suspend or resume selected applications"
    And I press "Change state" and I confirm dialog box within fancybox
    Then I should see "Required parameter missing: action"

  Scenario: Accept applications
    Given I am logged in as provider "foo.3scale.localhost"
      And I am on the applications admin page

    When I follow "Name"
     And I check select for "PendingApp" and "SuspendedApp"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected applications"

    When I select "Accept" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    When I go to the applications admin page
     And I follow "Name"

    # there is no transision suspended => live
    Then I should see following table:
     | Name ▲       | State     |
     | LiveApp      | live      |
     | PendingApp   | live      |
     | SuspendedApp | suspended |

  Scenario: Suspend applications
    Given I am logged in as provider "foo.3scale.localhost"
      And I am on the applications admin page

    When I follow "Name"
     And I check select for "LiveApp" and "PendingApp"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected applications"

    When I select "Suspend" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    When I go to the applications admin page
     And I follow "Name"

    # pending cannot be changed to suspended
    Then I should see following table:
     | Name ▲       | State     |
     | LiveApp      | suspended |
     | PendingApp   | pending   |
     | SuspendedApp | suspended |

  Scenario: Resume applications
    Given I am logged in as provider "foo.3scale.localhost"
      And I am on the applications admin page

    When I follow "Name"
     And I check select for "SuspendedApp" and "PendingApp"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected applications"

    When I select "Resume" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    When I go to the applications admin page
     And I follow "Name"

    # resume = suspended => live
    Then I should see following table:
     | Name ▲       | State   |
     | LiveApp      | live    |
     | PendingApp   | pending |
     | SuspendedApp | live    |
