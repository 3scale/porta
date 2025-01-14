@ignore-backend
Feature: Menu of the buyers
  In order to have an useful buyer area
  A buyer
  Has an useful menu

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_applications" visible
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name    | State     |
      | My API  | Default | Published |
    And a buyer "bob" signed up to application plan "Default"

  Scenario: Without live applications menu item Stats is not visible
    Given buyer "bob" has no live applications
    When I log in as "bob" on foo.3scale.localhost
    And I go to the dashboard
    Then I should not see "Statiscis"

