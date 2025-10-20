@javascript
Feature: Support emails settings management
  In order to control the support email settings
  As a provider
  I want to be able to manage the support emails

  Background:
    Given a provider is logged in

  Scenario: Support emails settings
    Given the provider has "finance" switch allowed
    And I go to the emails settings page
    Then the "Support email" field should contain the support email of provider "foo.3scale.localhost"
    And the "Finance support email" field should contain the finance support email of provider "foo.3scale.localhost"
    And the "Service API" field should contain the support email of service "API" of provider "foo.3scale.localhost"
    When I fill in "Support email" with "support-email@3scale.localhost"
    And I fill in "Finance support email" with "finance-email@3scale.localhost"
    And I fill in "Service API" with "support-default-service@3scale.localhost"
    And I press "Save"
    Then I should see "Your support emails have been updated"
    And provider "foo.3scale.localhost" support email should be "support-email@3scale.localhost"
    And provider "foo.3scale.localhost" finance support email should be "finance-email@3scale.localhost"
    And support email for service "API" of provider "foo.3scale.localhost" should be "support-default-service@3scale.localhost"

  Scenario: Support emails settings validations
    Given the provider has "finance" switch allowed
    And I go to the emails settings page
    Then the "Support email" field should contain the support email of provider "foo.3scale.localhost"
    And the "Finance support email" field should contain the finance support email of provider "foo.3scale.localhost"
    And the "Service API" field should contain the support email of service "API" of provider "foo.3scale.localhost"
    When I fill in "Support email" with "invalid support email"
    And I fill in "Finance support email" with "invalid support email"
    And I fill in "Service API" with "invalid support email"
    And I press "Save"
    # FIXME: With Javscript enanbled, the following is invalid because the form cannot be submitted
    # beacuse of HTML5 validations. Finish testing this.
    # Then I should see "There were errors saving some of your emails. Please review the marked fields"
    # And I should see error in provider side fields:
    #   | errors                |
    #   | Support email         |
    #   | Finance support email |
    #   | Service API           |
    Then I should not see "Your support emails have been updated"

  Scenario: Finance Support email does not show when finance denied
    Given the provider has "finance" switch denied
    And I go to the emails settings page
    Then I should not see field "Finance support email"
