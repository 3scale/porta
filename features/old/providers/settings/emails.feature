@javascript
Feature: Support emails settings management
  In order to control the support email settings
  As a provider
  I want to be able to manage the support emails

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"

  Scenario: Support emails settings
    Given provider "foo.example.com" has "finance" switch allowed
    When I log in as provider "foo.example.com"
      And I go to the emails settings page
    Then the "Support email" field should contain the support email of provider "foo.example.com"
      And the "Finance support email" field should contain the finance support email of provider "foo.example.com"
      And the "Service API" field should contain the support email of service "API" of provider "foo.example.com"

    When I fill in "Support email" with "invalid support email"
      And I fill in "Finance support email" with "invalid support email"
      And I fill in "Service API" with "invalid support email"
      And I press "Save"
    Then I should see "There were errors saving some of your emails. Please review the marked fields"
      And I should see error in provider side fields:
        | errors                |
        | Support email         |
        | Finance support email |
        | Service API           |

    When I fill in "Support email" with "support-email@example.com"
      And I fill in "Finance support email" with "finance-email@example.com"
      And I fill in "Service API" with "support-default-service@example.com"
      And I press "Save"
    Then I should see "Your support emails have been updated"
      And provider "foo.example.com" support email should be "support-email@example.com"
      And provider "foo.example.com" finance support email should be "finance-email@example.com"
      And support email for service "API" of provider "foo.example.com" should be "support-default-service@example.com"


  Scenario: Finance Support email does not show when finance denied
    Given provider "foo.example.com" has "finance" switch denied
    When I log in as provider "foo.example.com"
      And I go to the emails settings page
    Then I should not see field "Finance support email"
