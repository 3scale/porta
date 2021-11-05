@javascript
Feature: Create application from product context
  In order to control the way my buyers are using my API
  As a provider
  I want to create their applications

  Background:
    Given a provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" has no applications
    And a default application plan "Basic" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    Then I log in as provider "foo.3scale.localhost"

  Scenario: Create a an application
    When I create an application "My App" from the product "API" context
    Then I should be on the provider side "My App" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create an application in single application mode
    Given provider "foo.3scale.localhost" has multiple applications disabled
    And the provider "foo.3scale.localhost" has the following applications:
      | Buyer | Name    | Plan      |
      | bob   | BobApp  | Basic     |
    Then I should not be allowed to create more applications for product "API"
    And buyer "bob" should still have 1 cinstance

  Scenario: Create an application without being subscribed to any service
    Given buyer "bob" is not subscribed to the default service of provider "foo.3scale.localhost"
    When I create an application "My App" from the product "API" context
    Then I should be on the provider side "My App" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create an application for a service that doesn't allow choosing the plan
    Given a service "My API" of provider "foo.3scale.localhost"
    And a default application plan "Default Plan" of service "My API"
    When I create an application "My App" from the product "My API" context
    Then I should be on the provider side "My App" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create an application with no application plans
    Given a service "No plans API" of provider "foo.3scale.localhost"
    When I go to the product context create application page for "No plans API"
    Then I won't be able to select an application plan

  Scenario: Create an application for a service that doesn't allow choosing the plan and no default plan
    Given a service "Not Broken API" of provider "foo.3scale.localhost"
    And a published application plan "App plan" of service "Not Broken API"
    When I go to the product context create application page for "Not Broken API"
    Then I fill in the new application form
    And I should see button "Create Application"

  Scenario: Create an application when the service doesn't have a service plan
    Given provider "foo.3scale.localhost" has "service_plans" switch allowed
    And a service "Unsubscribed API" of provider "foo.3scale.localhost" with no service plans
    When I go to the product context create application page for "Unsubscribed API"
    And I fill in the new application form
    Then I should see "In order to subscribe the Application to a Product’s Application plan, this Account needs to subscribe to a Product’s Service plan."

  Scenario: Create an application with a required extra field
    Given provider "foo.3scale.localhost" has the following fields defined for "Cinstance":
      | name   | required | read_only | hidden |
      | wololo | true     |           |        |
    When I go to the product context create application page for "API"
    And I fill in the new application form with extra fields:
      | field   | value   |
      | Wololo  | wololo  |
    And I press "Create Application"
    Then I should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Submit button should be disabled until form is filled
    Given service "API" allows to choose plan on app creation
    When I go to the product context create application page for "API"
    And I should see button "Create Application" disabled
    And I select "bob" from "Account"
    And I should see button "Create Application" disabled
    And I select "Basic" from "Application plan"
    And I should see button "Create Application" disabled
    And I fill in "Name" with "Name"
    And I should see button "Create Application" disabled
    And I fill in "Description" with "Description"
    Then I should see button "Create Application"

  Scenario: Create an application with a pending contract
    Given buyer "bob" is subscribed with state "pending" to the default service of provider "foo.3scale.localhost"
    When I create an application "My App" from the product "API" context
    Then I should see "must have an approved subscription to service"
