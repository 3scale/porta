@javascript
Feature: Create application from Audience
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
    When I create an application "My App" from the audience context
    Then I should be on the provider side "My App" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create an application in single application mode
    Given provider "foo.3scale.localhost" has multiple applications disabled
    And the provider "foo.3scale.localhost" has the following applications:
      | Buyer | Name    | Plan      |
      | bob   | BobApp  | Basic     |
    Then I should not be allowed to create more applications
    And buyer "bob" should still have 1 cinstance

  Scenario: Create an application without being subscribed to any service
    Given buyer "bob" is not subscribed to the default service of provider "foo.3scale.localhost"
    When I create an application "My App" from the audience context
    Then I should be on the provider side "My App" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create an application for a service that doesn't allow choosing the plan
    When I create an application "My App" from the audience context
    Then I should be on the provider side "My App" application page
    And should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Create an application with no application plans
    Given a service "No plans API" of provider "foo.3scale.localhost"
    When I go to the provider new application page
    And I fill in the new application form for product "No plans API"
    Then I won't be able to select an application plan

  Scenario: Create an application when the service doesn't have a service plan
    Given provider "foo.3scale.localhost" has "service_plans" switch allowed
    And a service "Unsubscribed API" of provider "foo.3scale.localhost" with no service plans
    When I go to the provider new application page
    And I fill in the new application form for product "Unsubscribed API"
    Then I should see "To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product."

  Scenario: Create an application with a required extra field
    Given provider "foo.3scale.localhost" has the following fields defined for "Cinstance":
      | name   | required | read_only | hidden |
      | wololo | true     |           |        |
    When I go to the provider new application page
    And I fill in the new application form with extra fields:
      | field   | value   |
      | Wololo  | wololo  |
    And I press "Create application"
    Then I should see "Application was successfully created"
    And buyer "bob" should have 1 cinstance

  Scenario: Submit button should be disabled until form is filled
    When I go to the provider new application page
    And I should see button "Create application" disabled
    And I select "bob" from "Account"
    And I should see button "Create application" disabled
    And I select "API" from "Product"
    And I should see button "Create application" disabled
    And I select "Basic" from "Application plan"
    And I should see button "Create application" disabled
    And I fill in "Name" with "Name"
    And I should see button "Create application" disabled
    And I fill in "Description" with "Description"
    Then I should see button "Create application"

  Scenario: Create an application with a pending contract
    Given buyer "bob" is subscribed with state "pending" to the default service of provider "foo.3scale.localhost"
    When I create an application "My App" from the audience context
    Then I should see "must have an approved subscription to service"
