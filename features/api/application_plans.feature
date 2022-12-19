@javascript
Feature: Application plans index page

  In order to manage application plans from the index page, I want to perform the following
  actions: create, copy, edit, delete, publish and hide. Moreover, I want to sort the table
  by name, no. of apps and state.

  Background:
    Given a provider is logged in

  Scenario: Set a default application plan
    When an admin selects an application plan as default
    Then any new application will use this plan

  Scenario: Hidden plans can be default
    When an admin selects a hidden application plan as default
    Then any new application will use this plan

  Scenario: Selected default plan doesn't exist
    When an application plan has been deleted
    Then an admin can't select the plan as default

  Scenario: Create an application plan
    When an admin is in the application plans page
    Then they can add new application plans

  Scenario: Copy an application plan
    When an admin selects the action copy of an application plan
    Then a copy of the plan is added to the list

  Scenario: Edit an application plan
    When an admin clicks on an application plan
    Then they can edit its details

  Scenario: Delete an application plan
    When an application plan is not being used in any applications
    Then an admin can delete it from the application plans page

  Scenario: Delete an application plan is not allowed if subscribed to any application
    When an application plan is being used in an application
    Then an admin cannot delete it from the application plans page

  Scenario: Hide an application plan
    When an admin hides a plan from the application plans page
    Then the plan is hidden
    And a buyer won't be able to use it for their applications

  Scenario: Publish an application plan
    When an admin publishes a plan from the application plans page
    Then the plan is published
    And a buyer will be able to use it for their applications

  Scenario: Unset the default application plan
    When the default application plan is set
    And an admin unsets the default application plan
    Then the service will not have the default plan set

  @search
  Scenario: Filtering and sorting application plans
    When an admin is looking for an application plan
    Then they can filter plans by name
    And they can sort plans by name, no. of contracts and state
