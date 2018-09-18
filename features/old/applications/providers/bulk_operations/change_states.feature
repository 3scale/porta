@javascript
Feature: Bulk operations
  In order to approve or reject accounts quickly
  As a provider
  I want to change account states in bulk

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled

    Given a default application plan "Bronze" of provider "foo.example.com"
      And a buyer "Bob" signed up to provider "foo.example.com"
      And buyer "Bob" has the following applications:
      | name       | state   |
      | PendingApp | pending |
      | LiveApp    | live    |
      | SuspendedApp | suspended |

    Given current domain is the admin domain of provider "foo.example.com"
      And I don't care about application keys

  Scenario: Accept applications
    Given I am logged in as provider "foo.example.com"
      And I am on the applications admin page

    When I follow "Name"
     And I check select for "PendingApp" and "SuspendedApp"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected applications"

    When I select "Accept" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    # there is no transision suspended => live
    Then I should see following table:
     | Name ▲       | State     |
     | LiveApp      | live      |
     | PendingApp   | live      |
     | SuspendedApp | suspended |

  Scenario: Suspend applications
    Given I am logged in as provider "foo.example.com"
      And I am on the applications admin page

    When I follow "Name"
     And I check select for "LiveApp" and "PendingApp"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected applications"

    When I select "Suspend" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    # pending cannot be changed to suspended
    Then I should see following table:
     | Name ▲       | State     |
     | LiveApp      | suspended |
     | PendingApp   | pending   |
     | SuspendedApp | suspended |

  Scenario: Resume applications
    Given I am logged in as provider "foo.example.com"
      And I am on the applications admin page

    When I follow "Name"
     And I check select for "SuspendedApp" and "PendingApp"
     And I press "Change state"

    Then I should see "Accept, suspend or resume selected applications"

    When I select "Resume" from "Action"
     And I press "Change state" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"

    # resume = suspended => live
    Then I should see following table:
     | Name ▲       | State   |
     | LiveApp      | live    |
     | PendingApp   | pending |
     | SuspendedApp | live    |

