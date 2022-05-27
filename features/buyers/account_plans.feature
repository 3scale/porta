@javascript
Feature: Account plans index page

  In order to manage account plans from the index page, I want to perform the following
  actions: create, copy, edit, delete, publish and hide. Moreover, I want to sort the table
  by name, no. of apps and state.

  Rule: Account plans allowed

    Background:
      Given a provider is logged in
      And provider "foo.3scale.localhost" has "account_plans" switch allowed

    Scenario: Subscription section is visible
      Then an admin is able to see its account plans

    Scenario: Set a default account plan
      When an admin selects a published account plan as default
      Then new accounts will subscribe to this plan

    Scenario: Hidden plans can be default
      When an admin selects a hidden account plan as default
      Then new accounts will subscribe to this plan

    Scenario: Create an account plan
      Given an admin is in the account plans page
      Then they can add new account plans

    Scenario: Copy an account plan
      When an admin selects the action copy of an account plan
      Then a copy of the plan is added to the list

    Scenario: Edit an account plan
      When an admin clicks on an account plan
      Then they can edit its details

    Scenario: Delete an account plan
      When a buyer is not subscribed to the provider using an account plan
      Then an admin can delete it from the account plans page

    Scenario: Delete an account plan is not allowed if buyer subscribed
      When a buyer is subscribed to the provider using an account plan
      Then an admin cannot delete it from the account plans page

    @wip
    Scenario: Hide an account plan
      When an admin hides a plan from the account plans page
      # Then what happens?

    @wip
    Scenario: Publish an account plan
      When an admin publishes a plan from the account plans page
      # Then what happens?

    @search
    Scenario: Filtering and sorting account plans
      When an admin is looking for an account plan
      Then they can filter plans by name
      And they can sort plans by name, no. of contracts and state

  Rule: Account plans hidden

    Background:
      Given a provider is logged in
      And provider "foo.3scale.localhost" has "account_plans" switch denied

    Scenario: Account plans are unaccessible
      Given a product
      Then an admin is not able to see its account plans
