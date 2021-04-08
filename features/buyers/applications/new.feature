@javascript @ignore-backend
Feature: Create application
  In order to control the way my buyers are using my API
  As a provider
  I want to create their applications

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" uses backend v2 in his default service
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "service_plans" switch allowed
    And a default application plan "Basic" of provider "foo.3scale.localhost"
    And plan "Basic" is published
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" is subscribed to the default service of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

  Scenario: Create a single application in single application mode
    Given plan "Basic" is customized
    And provider "foo.3scale.localhost" has multiple applications disabled
    And buyer "bob" has no applications
    And I go to the account context create application page for "bob"
    Then I should see "New Application"
    And I select "API" from "Product"
    And I select "Default" from "Service plan"
    But the application plans select should not contain custom plans of provider "foo.3scale.localhost"
    And I select "Basic" from "Application plan"
    And I fill in "Name" with "UltimateWidget"
    And I fill in "Description" with "Awesome ultimate super widget"
    And I press "Create Application"
    And I should be on the provider side "UltimateWidget" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance
    When I go to the buyer account page for "bob"
    And I follow "1 Application"
    Then I should see "Create Application"

  Scenario: Create a new application from Account context
    Given plan "Basic" is customized
    And buyer "bob" has no applications
    And I go to the account context create application page for "bob"
    Then I should see "New Application"
    And I select "API" from "Product"
    And I select "Default" from "Service plan"
    But the application plans select should not contain custom plans of provider "foo.3scale.localhost"
    And I select "Basic" from "Application plan"
    And I fill in "Name" with "UltimateWidget"
    And I fill in "Description" with "Awesome ultimate super widget"
    And I press "Create Application"
    Then I should be on the provider side "UltimateWidget" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create a new application from Product context
    Given plan "Basic" is customized
    And buyer "bob" has no applications
    And I go to the product context create application page for "API"
    Then I should see "New Application"
    And I select "bob" from "Account"
    And I select "Default" from "Service plan"
    But the application plans select should not contain custom plans of provider "foo.3scale.localhost"
    And I select "Basic" from "Application plan"
    And I fill in "Name" with "UltimateWidget"
    And I fill in "Description" with "Awesome ultimate super widget"
    And I press "Create Application"
    Then I should be on the provider side "UltimateWidget" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create a new application from Audience context
    Given plan "Basic" is customized
    And buyer "bob" has no applications
    And I go to the audience context create application page
    Then I should see "New Application"
    And I select "bob" from "Account"
    And I select "API" from "Product"
    And I select "Default" from "Service plan"
    But the application plans select should not contain custom plans of provider "foo.3scale.localhost"
    And I select "Basic" from "Application plan"
    And I fill in "Name" with "UltimateWidget"
    And I fill in "Description" with "Awesome ultimate super widget"
    And I press "Create Application"
    Then I should be on the provider side "UltimateWidget" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create a new application without having a service subscription
    Given a service "second" of provider "foo.3scale.localhost"
    And provider has "service_plans_ui_visible" hidden
    And a published service plan "non_default" of service "second" of provider "foo.3scale.localhost"
    And a published application plan "second_app_plan" of service "second" of provider "foo.3scale.localhost"
    And buyer "bob" is not subscribed to the default service of provider "foo.3scale.localhost"
    And I go to the account context create application page for "bob"
    Then I should see "New Application"
    And I fill in "Name" with "UltimateWidget"
    And I fill in "Description" with "Awesome ultimate super widget"
    And I select "second" from "Product"
    And I select "second_app_plan" from "Application plan"
    And I select "non_default" from "Service plan"
    And I press "Create Application"
    Then I should see "Application was successfully created."
    Then buyer "bob" should have 1 cinstance
    And I should be on the provider side "UltimateWidget" application page
    And should see "Application was successfully created"

  Scenario: The service of the selected application plans does not have a service plan
    Given a service "second" of provider "foo.3scale.localhost"
    And a published application plan "second_app_plan" of service "second" of provider "foo.3scale.localhost"
    And the service "second" does not have service plan
    And buyer "bob" is not subscribed to the default service of provider "foo.3scale.localhost"
    And I go to the account context create application page for "bob"
    Then I should see "New Application"
    And I fill in "Name" with "UltimateWidget"
    And I fill in "Description" with "Awesome ultimate super widget"
    And I select "second" from "Product"
    And I select "second_app_plan" from "Application plan"
    Then I should see "In order to subscribe the Application to a Product’s Application plan, this Account needs to subscribe to a Product’s Service plan."
    And I should see "Create a new Service plan"

  Scenario: Create an application with extra field
    Given provider "foo.3scale.localhost" has the following fields defined for "Cinstance":
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
    And I select "API" from "Product"
    And I select "Basic" from "Application plan"
    And I select "Default" from "Service plan"
    And I press "Create Application"
    Then I should be on the provider side "UltimateWidget" application page
    And should see "Application was successfully created"
    And  buyer "bob" should have 1 cinstance

  Scenario: Submit button should be disabled
    When I go to the account context create application page for "bob"
    Then I should see "New Application"
    And I should see button "Create Application" disabled
    Then I fill in "Name" with "Name"
    And I should see button "Create Application" disabled
    Then I fill in "Description" with "Description"
    And I should see button "Create Application" disabled
    Then I select "API" from "Product"
    And I should see button "Create Application" disabled
    Then I select "Default" from "Service plan"
    And I should see button "Create Application" disabled
    Then I select "Basic" from "Application plan"
    And I should see button "Create Application"

  Scenario: Create an application with a pending contract
    Given buyer "bob" is subscribed with state "pending" to the default service of provider "foo.3scale.localhost"
    And I go to the account context create application page for "bob"
    When I should see "New Application"
    And I select "API" from "Product"
    And I select "Default" from "Service plan"
    And I select "Basic" from "Application plan"
    And I fill in "Name" with "name"
    And I fill in "Description" with "description"
    And I press "Create Application"
    Then I should see "must have an approved subscription to service"
