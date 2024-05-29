@javascript
Feature: Master Portal Provider's Plan Settings
  In order to manage provider accounts
  As a master
  I want to be able to change its plan settings

  Background:
    Given master admin is logged in
    And the default product of provider "master" has name "Master API"
    And the following application plan:
      | Product    | Name     | State     |
      | Master API | Basic    | Published |
    And a provider "banana.example.org" signed up to plan "Basic"

  Rule: Finance setting

    Scenario: Finance module is allowed
      Given provider "banana.example.org" has "finance" allowed
      When they go to the overview page of account "banana.example.org"
      Then setting "Finance" should be hidden

    Scenario: Finance module is denied
      Given provider "banana.example.org" has "finance" denied
      When they go to the overview page of account "banana.example.org"
      Then setting "Finance" should be denied

    Scenario: Enabling finance module
      Given provider "banana.example.org" has "finance" denied
      And provider "banana.example.org" is not able to access billing
      When they go to the overview page of account "banana.example.org"
      Then setting "Finance" can be enabled
      And provider "banana.example.org" is able to access billing

    Scenario: Change the plan
      Given the following application plans:
        | Product    | Name     | State     |
        | Master API | Advanced | Published |
      And they go to the overview page of account "banana.example.org"
      When they select "Advanced" from "Change plan"
      And press "Change plan"
      Then they should see "Upgrade 'banana.example.org'"
      And should see "You are changing the plan from Basic to Advanced."
      Then they press "Yes, change the plan to Advanced"
      And should see the flash message "Plan upgraded."
