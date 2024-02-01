@javascript
Feature: Audience > Accounts > Listing > Account > Applications > New

  Background:
    Given a provider
    And the provider has multiple applications enabled
    And a product "My API"
    And the following application plan:
      | Product | Name  |
      | My API  | Basic |
    And a buyer "Jane"
    And the following application:
      | Buyer | Name   | Product |
      | Jane  | My App | My API  |
    And the provider logs in

  Scenario: Navigation
    Given they go to buyer "Jane" applications page
    When they follow "Create application"
    Then the current page is buyer "Jane" new application page

  Scenario: Create an application
    Given they go to buyer "Jane" new application page
    When the form is submitted with:
      | Product          | My API         |
      | Application plan | Basic          |
      | Name             | New App        |
      | Description      | This is an app |
    Then the current page is application "New App" admin page
    And they should see the flash message "Application was successfully created"

  Scenario: Create an application without being subscribed to a product
    Given the buyer is not subscribed to product "My API"
    And they go to buyer "Jane" new application page
    When the form is submitted with:
      | Product          | My API         |
      | Application plan | Basic          |
      | Name             | New App        |
      | Description      | This is an app |
    Then the current page is application "New App" admin page
    And they should see the flash message "Application was successfully created"

  Scenario: Create an application for a subscribed product
    Given the buyer is subscribed to product "My API"
    And they go to buyer "Jane" new application page
    When the form is submitted with:
      | Product          | My API         |
      | Application plan | Basic          |
      | Name             | New App        |
      | Description      | This is an app |
    Then the current page is application "New App" admin page
    And they should see the flash message "Application was successfully created"

  Scenario: Create an application when product has no application plans
    Given a product "No plans API" with no plans
    And they go to buyer "Jane" new application page
    When select "No plans API" from "Product"
    Then they should see "No application plans exist for the selected product"
    And select "Application plan" is disabled

  Scenario: Create an application with a required extra field
    Given the provider has the following fields defined for applications:
      | name   | required | read_only | hidden |
      | Banana | true     |           |        |
    When they go to buyer "Jane" new application page
    And the form is submitted with:
      | Product          | My API         |
      | Application plan | Basic          |
      | Name             | New App        |
      | Banana           | wololo         |
    Then the current page is application "New App" admin page
    And they should see the flash message "Application was successfully created"

  Scenario: Submit button should be disabled until form is filled
    Given they go to buyer "Jane" new application page
    And the submit button is disabled
    When they select "My API" from "Product"
    And the submit button is disabled
    And select "Basic" from "Application plan"
    And the submit button is disabled
    And fill in "Name" with "Name"
    Then the submit button is enabled

  Scenario: Create an application with a pending contract
    Given the buyer is subscribed to product "My API"
    But the subscription is pending
    When they go to buyer "Jane" new application page
    And the form is submitted with:
      | Product          | My API         |
      | Application plan | Basic          |
      | Name             | New App        |
      | Description      | This is an app |
    Then they should see the flash message "must have an approved subscription to service"

  Rule: Multiple applications denied
    Background:
      Given the provider has multiple applications disabled

    Scenario: Manual navigation
      Given they go to buyer "Jane" applications page
      When they follow "Create application"
      Then the current page is the upgrade notice for multiple applications

    Scenario: Navigation via url
      Given they go to buyer "Jane" new application page
      When the form is submitted with:
        | Product          | My API        |
        | Application plan | Basic         |
        | Name             | Forbidden App |
      Then they should see "Access denied"

  Rule: Service plans allowed
    Background:
      Given the provider has "service_plans" switch allowed

    Scenario: Create an application when the product has no service plans
      Given a product "Unsubscribed API" with no service plans
      When they go to buyer "Jane" new application page
      And select "Unsubscribed API" from "Product"
      Then they should see "To subscribe the application to an application plan of this product, you must subscribe this account to a service plan linked to this product."
