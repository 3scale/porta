@javascript @ignore-backend
Feature: Applications details
  In order to manage application keys
  As a provider
  I want to be able to add and remove keys

  Background:
  Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And a default application plan of provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"
  Given current domain is the admin domain of provider "foo.example.com"

  Scenario: Set custom user key
    Given provider "foo.example.com" uses backend v1 in his default service
      And buyer "bob" has application "AjaxApp"
      And I am logged in as provider "foo.example.com"

    When I navigate to the application "AjaxApp" of the partner "bob"
     And I follow "Set Custom Key"
     And I fill in "Custom User Key" with "my-custom-key"
     And I press "Set Custom Key"
    Then I should see "my-custom-key"
     And application "AjaxApp" should have user key "my-custom-key"

  Scenario: Set custom user key fails
    Given provider "foo.example.com" uses backend v1 in his default service
      And buyer "bob" has application "AjaxApp"
      And I am logged in as provider "foo.example.com"

    When I navigate to the application "AjaxApp" of the partner "bob"
     And I follow "Set Custom Key"
     And I fill in "Custom User Key" with "invalid-Ñ$%"
     And I press "Set Custom Key"
    Then I should see "Invalid key"

  @ajax
  Scenario: Remove and add keys
    Given provider "foo.example.com" uses backend v2 in his default service
      And I am logged in as provider "foo.example.com"
      And buyer "bob" has application "AjaxApp"
      And the key limit for application "AjaxApp" is reached

    When I navigate to the application "AjaxApp" of the partner "bob"

    Then I should see application keys limit reached error

    When I follow "Delete" for first application key

    Then I should not see application keys limit reached error
      And I should see "Add Random key"
      And I should see "Add Custom key"

    When I follow "Add Random key"
    Then I should see application keys limit reached error
