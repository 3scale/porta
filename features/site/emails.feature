@javascript
Feature: Audience > Messages > Settings > Support emails

  As a provider I want to be able to manage my account, finance and products support emails

  Background:
    Given a provider with:
      | Support email         | support@api.test         |
      | Finance support email | finance-support@api.test |
    And the provider logs in

  Scenario: Update emails
    Given they go to the emails settings page
    And field "Primary support email" has value "support@api.test"
    And field "Finance support email" has value "finance-support@api.test"
    When the form is submitted with:
      | Primary support email | foo@api.test         |
      | Finance support email | finance-foo@api.test |
    Then they should see the flash message "Your support emails have been updated"
    And the provider support email should be "foo@api.test"
    And the provider finance support email should be "finance-foo@api.test"

  Scenario: Finance support email default value
    Given they go to the emails settings page
    When the form is submitted with:
      | Primary support email | default@api.test |
      | Finance support email |                  |
    Then they should see the flash message "Your support emails have been updated"
    And the provider finance support email should be "default@api.test"

  Scenario: Products support email default value
    Given a product "Bananas"
    And the support email for service "Bananas" of the provider should be "support@api.test"
    When they go to the emails settings page
    And press "Add an exception"
    # TODO

  Scenario: DNS domains are readonly
    Given DNS domains are readonly
    When they go to the emails settings page
    Then they should see "Outbound Email Addresses"

  Scenario: DNS domains are not readonly
    Given DNS domains are not readonly
    When they go to the emails settings page
    Then they should not see "Outbound Email Addresses"
