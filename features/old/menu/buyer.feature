@ignore-backend
Feature: Menu of the buyers
  In order to have an useful buyer area
  A buyer
  Has an useful menu

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And an application plan "Default" of provider "foo.example.com"
    And a buyer "bob" signed up to application plan "Default"


  Scenario: Without live applications menu item Stats is not visible
    Given buyer "bob" has no live applications
    When I log in as "bob" on foo.example.com
    And I go to the dashboard
    Then I should not see "Statiscis"

