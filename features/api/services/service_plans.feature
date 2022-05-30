@javascript
Feature: Service plans index page

  In order to manage service plans from the index page, I want to perform the following
  actions: create, copy, edit, delete, publish and hide. Moreover, I want to sort the table
  by name, no. of apps and state.

  Rule: Service plans allowed

    Background:
      Given a provider is logged in
      And provider "foo.3scale.localhost" has "service_plans" switch allowed

    Scenario: Subscription section is visible
      Given a product
      Then an admin is able to see its service plans

    Scenario: Set a default service plan
      Given a product
      When an admin selects a published service plan as default
      Then any new application of that product will be subscribed using this plan

    Scenario: Hidden plans can be default
      Given a product
      When an admin selects a hidden service plan as default
      Then any new application of that product will be subscribed using this plan

    Scenario: Selected default plan doesn't exist
      When a service plan has been deleted
      Then an admin can't select the plan as default

    Scenario: Create a service plan
      When an admin is in the service plans page
      Then they can add new service plans

    Scenario: Copy a service plan
      When an admin selects the action copy of a service plan
      Then a copy of the plan is added to the list

    Scenario: Edit a service plan
      When an admin clicks on a service plan
      Then they can edit its details

    Scenario: Delete a service plan
      When a service plan is not being used in any applications
      Then an admin can delete it from the service plans page

    Scenario: Delete a service plan is not allowed if subscribed to any application
      When a service plan is being used in an application
      Then an admin cannot delete it from the service plans page

    @wip
    Scenario: Hide a service plan
      When an admin hides a plan from the service plans page
      # Then what happens?

    @wip
    Scenario: Publish a service plan
      When an admin publishes a plan from the service plans page
      # Then what happens?

    @search @wip
    Scenario: Filtering and sorting service plans
      When an admin is looking for a service plan
      Then they can filter plans by name
      And they can sort plans by name, no. of contracts and state

Rule: service plans hidden

  Background:
    Given a provider is logged in
    And provider "foo.3scale.localhost" has "service_plans" switch denied

  Scenario: service plans are unaccessible
    Given a product
    Then an admin is not able to see its service plans
