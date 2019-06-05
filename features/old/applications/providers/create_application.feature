@ignore-backend @javascript
Feature: Create application
  In order to control the way my buyers are using my API
  As a provider
  I want to create their applications

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "service_plans" switch allowed
    And a default application plan "Basic" of provider "foo.example.com"
    And plan "Basic" is published
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" is subscribed to the default service of provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"


  #TODO move single_app mode examples to separate feature?
  Scenario: Create a single application in single application mode
    Given plan "Basic" is customized
    Given provider "foo.example.com" has multiple applications disabled
      And buyer "bob" has no applications
      And I go to the provider side create application page for "bob"
    Then I should see "New Application"
     But the application plans select should not contain custom plans of provider "foo.example.com"
     And I fill in "Name" with "UltimateWidget"
     And I fill in "Description" with "Awesome ultimate super widget"
     And I select "Basic" from "Application plan"
     And I press "Create"
     And I should be on the provider side "UltimateWidget" application page
     And should see "Application was successfully created"
     And  buyer "bob" should have 1 cinstance
    When I go to the buyer account page for "bob"
    And I follow "1 Application"
    Then I should see "Create Application"

  Scenario: Create a new application
    Given plan "Basic" is customized
    Given buyer "bob" has no applications
      And I go to the provider side create application page for "bob"
    Then I should see "New Application"
     But the application plans select should not contain custom plans of provider "foo.example.com"
     And I fill in "Name" with "UltimateWidget"
     And I fill in "Description" with "Awesome ultimate super widget"
     And I select "Basic" from "Application plan"
     And I press "Create"

     Then I should be on the provider side "UltimateWidget" application page
     And should see "Application was successfully created"
     And buyer "bob" should have 1 cinstance

  Scenario: Create a new application without having a service subscription
    Given a service "second" of provider "foo.example.com"
      And provider has "service_plans_ui_visible" hidden
      And a published service plan "non_default" of service "second" of provider "foo.example.com"
      And a published application plan "second_app_plan" of service "second" of provider "foo.example.com"
      And buyer "bob" is not subscribed to the default service of provider "foo.example.com"

      And I go to the provider side create application page for "bob"
     Then I should see "New Application"
      And I fill in "Name" with "UltimateWidget"
      And I fill in "Description" with "Awesome ultimate super widget"
      And I select "second_app_plan" from "Application plan"
      And I select "non_default" from "Service plan"
      And I press "Create"
      Then I should see "Application was successfully created."

     Then buyer "bob" should have 1 cinstance
     And I should be on the provider side "UltimateWidget" application page
     And should see "Application was successfully created"

   Scenario: The service of the selected application plans hasn´t service plan
     Given a service "second" of provider "foo.example.com"
       And a published application plan "second_app_plan" of service "second" of provider "foo.example.com"
       And buyer "bob" is not subscribed to the default service of provider "foo.example.com"
       And I go to the provider side create application page for "bob"
      Then I should see "New Application"
       And I fill in "Name" with "UltimateWidget"
       And I fill in "Description" with "Awesome ultimate super widget"
       And I select "second_app_plan" from "Application plan"
      Then I should see "Create a service plan"

  Scenario: Create an application with extra field
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name | required | read_only | hidden |
      | womm | true     |           |        |

      And buyer "bob" has no applications
      And I go to the buyer account page for "bob"
      And I follow "0 Applications"
      And I follow "Create Application"
    Then I should see "New Application"
     And I fill in "Name" with "UltimateWidget"
     And I fill in "Description" with "Awesome ultimate super widget"
     And I fill in "Womm" with "12/10"

     And I select "Basic" from "Application plan"
     And I press "Create"

    Then I should be on the provider side "UltimateWidget" application page
     And should see "Application was successfully created"
     And  buyer "bob" should have 1 cinstance

  Scenario: Create an application should validate the fields
    When I go to the provider side create application page for "bob"
    Then I should see "New Application"
     And I fill in "Name" with ""
     And I fill in "Description" with ""
     And I select "Basic" from "Application plan"
     And I press "Create"
   Then I should see "can´t be blank" in the "Name" field
     And I should see "can´t be blank" in the "Description" field


  Scenario: Create an application with a pending contract
    Given buyer "bob" is subscribed with state "pending" to the default service of provider "foo.example.com"
    And  I go to the provider side create application page for "bob"
    When I should see "New Application"
    And I should see "Default (pending)"
    And I fill in "Name" with "name"
    And I fill in "Description" with "description"
    And I press "Create"
    Then I should see "must have an approved subscription to service"

  Scenario: Edit an application should validate the fields
     Given buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
     And I go to the buyer account page for "bob"
     And I follow "UltraWidget" within "#applications_widget"
     And I follow "Edit"
     Then I should see "Edit application: UltraWidget"
     When I fill in "Name" with ""
     And I press "Update Application"
     And should see "can't be blank"


  Scenario: Edit an application
    Given buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
    And I go to the buyer account page for "bob"
    And I follow "UltraWidget" within "#applications_widget"
    And I follow "Edit"
    Then I should see "Edit application: UltraWidget"
    When I fill in "Name" with "Not So Ultra Widget"
    And I press "Update Application"
    Then I should see "Application was successfully updated"
    And I should be on the provider side "Not So Ultra Widget" application page
    And I should see "Not So Ultra Widget" in a header


  # TODO: also in single app mode
  Scenario: Edit an application with extra fields
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name                | required | read_only | hidden |
      | app_extra_required  | true     |           |        |
      | app_extra_read_only |          | true      |        |
      | app_extra_hidden    |          |           | true   |

      And buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
      And I go to the provider side edit page for application "UltraWidget" of buyer "bob"
    When I fill in "Name" with "Not So Ultra Widget"
    When I fill in "App extra hidden" with "hidden but not for provider"
      And I press "Update Application"
    Then I should see "Application was successfully updated"
      And I should not see error in fields:
      | errors             |
      | App extra required |

    Then I should see "Not So Ultra Widget"
      And I should see "hidden but not for provider" in the "App extra hidden" field
