@backend
Feature: Buyer's application management
  In order to manage his/her applications of the web service
  A buyer
  Has access to applications management area

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "service_plans" visible
    And provider "foo.example.com" has "multiple_services" visible
    And an published application plan "Default" of provider "foo.example.com"
    And a service plan "Gold" of provider "foo.example.com"
    And a buyer "bob" signed up to service plan "Gold"
    And I don't care about application keys


  Scenario: Provider can deny access to applications Keys
    Given the provider "foo.example.com" does not allow its partners to manage application keys
      And buyer "bob" has application "SomeApp"
    When I log in as "bob" on foo.example.com
      And I go to the "SomeApp" application page
    Then I should not see the application keys

  @javascript @ajax
  Scenario: Can select a plan when creating a new application
    Given a service "Travelling" of provider "foo.example.com"
      And service "Travelling" allows to choose plan on app creation
      And a service plan "Holidays" of service "Travelling"
      And a published application plan "Plane" of service "Travelling"
      And a published application plan "Train" of service "Travelling"
      And buyer "bob" is subscribed to service plan "Holidays"
      And buyer "bob" is subscribed to service plan "Default"

    When the current domain is foo.example.com
      And I log in as "bob" on foo.example.com
      And I go to the dashboard
      And I follow "Applications"
      And I follow "Create new application"
      And I follow "Travelling"
      And I follow "Change"
      And I follow "Train"
      And I click on Select this plan for the "Train" plan

    When I fill in "Name" with "UltimateWidget"
     And I fill in "Description" with "Awesome ultimate super widget"
     And I press "Create"
     And I should be on the "UltimateWidget" application page
     And I should see "Name UltimateWidget"
     And I should see "Awesome ultimate super widget"
     And I should see "Plan Train"
     And buyer "bob" should have 1 cinstance

    Scenario: Cannot select a plan when creating a new application
      Given an application plan "Bronze" of provider "foo.example.com"
      And an application plan "Gold" of provider "foo.example.com"

      When I log in as "bob" on foo.example.com
      And I go to the dashboard
      And I follow "Applications"
      And I follow "Create new application"
      Then I should not be able to pick a plan

      When I fill in "Name" with "UltimateWidget"
      And I fill in "Description" with "Awesome ultimate super widget"
      And I press "Create"
      And I should see "Plan Default"
      And buyer "bob" should have 1 cinstance

  @javascript
  Scenario: Can request plan change on an already existing application
    Given buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
    And an published application plan "Bronze" of provider "foo.example.com"
   When I log in as "bob" on foo.example.com
    And I go to the applications page
    And I follow "UltraWidget"
    And I follow "Edit UltraWidget"
    Then I should see "Default › Review/Change"
    When I follow "Change"
    Then I should see a list of available plans
    | plan      | state  |
    | Default   | active |
    | Bronze    |        |

    When I follow "Bronze"
    And I request to change to plan "Bronze"
    Then I should see "A request to change your application plan has been sent"

  Scenario: Create a new application without published or default plan
    Given provider "foo.example.com" has no published application plans
      And provider "foo.example.com" has no default application plan
    When I log in as "bob" on foo.example.com
    And I go to the applications page
    Then I should not see "Create new application"

  Scenario: Create an application that requires approval
    Given provider "foo.example.com" requires cinstances to be approved before use
    When I log in as "bob" on foo.example.com
    And I go to the applications page
    And I follow "Create new application"
    And I fill in "Name" with "MegaWidget"
    And I fill in "Description" with "Bla bla bla"
    And I press "Create"
    Then I should see "Your application is awaiting approval"

  Scenario: Edit an application
    Given buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
    When I log in as "bob" on foo.example.com
    And I go to the applications page
    And I follow "UltraWidget" for application "UltraWidget"
    And I follow "Edit UltraWidget"
    And I fill in "Description" with "Slightly more awesome widget"
    And I press "Update"
    Then I should see "Application was successfully updated"
    And I should be on the "UltraWidget" application page
    And I should see "Slightly more awesome widget"
    And I should not see "Slightly less awesome widget"

  Scenario: Delete an application
    Given buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
    When I log in as "bob" on foo.example.com
    And I go to the applications page
    And I follow "UltraWidget" for application "UltraWidget"
    And I follow "Edit UltraWidget"
    And I follow "Delete UltraWidget" and I confirm dialog box
    Then I should see "Application was successfully deleted."
    And I should be on the applications page
    And I should not see "UltraWidget"

  Scenario: Application creation with fields
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name                 | required | read_only | hidden |
      | app_extra_required  | true     |           |        |
      | app_extra_read_only |          | true      |        |
      | app_extra_hidden    |          |           | true   |

    When I log in as "bob" on foo.example.com
      And I go to the new application page

    Then fields should be required:
      | required           |
      | App extra required |

    Then I should not see the fields:
      | not present         |
      | App extra read only |
      | App extra hidden    |

    When I press "Create Application"
    Then I should see error in fields:
      | errors             |
      | Name               |
      | Description        |
      | App extra required |

    When I fill in "Name" with "MyApp"
    And I fill in "Description" with "SuperApp"
    And I fill in "App extra required" with "MustBe"

    When I press "Create Application"
    Then I should see "MyApp"
      And I should see "SuperApp" in the "Description" field
      And I should see "MustBe" in the "App extra required" field

  Scenario: Application fields visibility for buyers
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name                | required | read_only | hidden |
      | app_extra_required  | true     |           |        |
      | app_extra_read_only |          | true      |        |
      | app_extra_hidden    |          |           | true   |

      And buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
      And application "UltraWidget" has extra field "app_extra_required" blank
    When I log in as "bob" on foo.example.com
      And I go to the "UltraWidget" application page
    Then I should not see "App extra required"
      And I should not see "App extra read only"
      And I should not see "App extra hidden"

  Scenario: Application update with fields
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name                | required | read_only | hidden |
      | app_extra_required  | true     |           |        |
      | app_extra_read_only |          | true      |        |
      | app_extra_hidden    |          |           | true   |

      And buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"

    When I log in as "bob" on foo.example.com
      And I go to the "UltraWidget" application edit page
    Then I should not see the fields:
      | not present         |
      | App extra read only |
      | App extra hidden    |

    When I leave "App extra required" blank
    When I press "Update Application"
    Then I should see error in fields:
      | errors             |
      | App extra required |

    When I fill in "App extra required" with "MustBe"
      And I press "Update Application"

    Then I should see "SuperApp" in the "Description" field
      And I should see "MustBe" in the "App extra required" field
    Then I should see "App extra required"
    And I should not see "App extra read only"
    And I should not see "App extra hidden"

  Scenario: Choose service when subscribed to many
    Given a service "Fancy" of provider "foo.example.com"
    Given a service "Awesome" of provider "foo.example.com"
    And a default service of provider "foo.example.com" has name "Boring"
    And an published application plan "AppPlan" of service "Awesome"
    And an published application plan "Fancy Plan" of service "Fancy"
    And a service plan "Good" of service "Fancy"
    And service plan "Good" requires approval
    And buyer "bob" subscribed service "Fancy" with plan "Good"
    And buyer "bob" subscribed service "Awesome"
    And I am logged in as "bob" on foo.example.com

    When I go to the applications page
     And I follow "Create new application"
    Then I should see "Boring"
     And I should not see "Fancy"
     And I should see "Awesome"

    When I go to the new application page for service "Fancy"
    Then I should be on the services list for buyers
