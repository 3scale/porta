@ignore-backend
Feature: Enabling billing and charging per buyer
  In order to allow special treatment of some buyers
  As a provider
  I want to be able exclude them from billing and/or charging process

  Background:
    Given a published plan "Pro" of provider "Master account"
      And a provider "foo.example.com" signed up to plan "Pro"
      And provider "foo.example.com" has "finance" switch allowed
      And provider "foo.example.com" is charging

      And an application plan "Basic" of provider "foo.example.com"
      And a buyer "bob's" signed up to application plan "Basic"

      And I am logged in as provider "foo.example.com" on its admin domain

  Scenario: Finance off disables monthly charging toggle
      And provider "foo.example.com" has "finance" switch denied
      And I go to the buyer account page for "bob's"
     Then I should not see "Monthly charging is enabled"

  @javascript
  Scenario: Monthly charging toggle
      And buyer "bob's" has "monthly charging" enabled
      And I go to the buyer account page for "bob's"
     Then I should see "Monthly charging is enabled"
     When I press "Disable charging" and I confirm dialog box
     Then I should see "Monthly charging is disabled"

  @javascript
  Scenario: Monthly billing toggle
      And buyer "bob's" has "monthly billing" enabled
      And I go to the buyer account page for "bob's"
     Then I should see "Monthly billing is enabled"
     When I press "Disable billing" and I confirm dialog box
     Then I should see "Monthly billing is disabled"
