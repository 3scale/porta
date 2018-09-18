Feature: Buyer account management
  In order to keep my buyer account information about my company or group up to date
  As a registered buyer user
  I want to see and change my account details

  Background:
    Given a provider "foo.example.com"
     And an application plan "Default" of provider "foo.example.com"
      And a buyer "bob" signed up to application plan "Default"

  Scenario: Account edit does not immeditaly shows validation errors (#7486981)
    When I am logged in as "bob" on foo.example.com
     And I go to the account edit page
    Then I should not see an error on company size

  Scenario: Account edit does not show timezone (#8573569)
    When I am logged in as "bob" on foo.example.com
     And I go to the account edit page
    Then I should not see the timezone field
