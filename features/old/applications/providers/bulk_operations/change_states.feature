@javascript
Feature: Bulk operations
  In order to approve or reject accounts quickly
  As a provider
  I want to change account states in bulk

  Background:
    Given a provider is logged in
    And the provider has multiple applications enabled
    Given a default application plan "Bronze" of provider "foo.3scale.localhost"
    And a buyer "Bob" signed up to provider "foo.3scale.localhost"
    And buyer "Bob" has the following applications:
      | name         | state     |
      | PendingApp   | pending   |
      | LiveApp      | live      |
      | SuspendedApp | suspended |
    And I don't care about application keys

  Scenario: Do nothing
    And I am on the applications admin page
    And I check select for "PendingApp" and "SuspendedApp"
    And I press "Change state"
    Then I should see "Accept, suspend or resume selected applications"
    And I press "Change state" and I confirm dialog box within fancybox
    Then I should see "Required parameter missing: action"

  Scenario: Accept applications
    And I am on the applications admin page
    When I follow "Name"
    And I check select for "PendingApp" and "SuspendedApp"
    And I press "Change state"
    Then I should see "Accept, suspend or resume selected applications"
    When I select "Accept" from "Action"
    And I press "Change state" and I confirm dialog box within fancybox
    Then I should see "Successfully changed the state of 2 applications."
    When I go to the applications admin page
    And I follow "Name"
    # there is no transision suspended => live
    Then I should see following table:
      | Name         | State     |
      | LiveApp      | live      |
      | PendingApp   | live      |
      | SuspendedApp | suspended |

  Scenario: Suspend applications
    And I am on the applications admin page
    When I follow "Name"
    And I check select for "LiveApp" and "PendingApp"
    And I press "Change state"
    Then I should see "Accept, suspend or resume selected applications"
    When I select "Suspend" from "Action"
    And I press "Change state" and I confirm dialog box within fancybox
    Then I should see "Successfully changed the state of 2 applications."
    When I go to the applications admin page
    And I follow "Name"
    # pending cannot be changed to suspended
    Then I should see following table:
      | Name         | State     |
      | LiveApp      | suspended |
      | PendingApp   | pending   |
      | SuspendedApp | suspended |

  Scenario: Resume applications
    And I am on the applications admin page
    When I follow "Name"
    And I check select for "SuspendedApp" and "PendingApp"
    And I press "Change state"
    Then I should see "Accept, suspend or resume selected applications"
    When I select "Resume" from "Action"
    And I press "Change state" and I confirm dialog box within fancybox
    Then I should see "Successfully changed the state of 2 applications."
    When I go to the applications admin page
    And I follow "Name"
    # resume = suspended => live
    Then I should see following table:
      | Name         | State   |
      | LiveApp      | live    |
      | PendingApp   | pending |
      | SuspendedApp | live    |

  Scenario: Error template shows correctly
    And I am on the applications admin page
    When I follow "Name"
    And I check select for "LiveApp"
    And I press "Change state"
    Then I should see "Accept, suspend or resume selected applications"
    When I select "Suspend" from "Action"
    Given the application will return an error when suspended
    And I press "Change state" and I confirm dialog box within fancybox
    Then I should see the bulk action failed with application "LiveApp"
