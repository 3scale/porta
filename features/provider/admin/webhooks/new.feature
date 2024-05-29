@javascript @webhook
Feature: Provider webhooks

  As a provider, I want to configure the webhook I have previously created.

  Background:
    Given a provider is logged in
    And the provider has "web_hooks" switch allowed

  Scenario: Navigation
    Given they go to the provider dashboard
    When they select "Account Settings" from the context selector
    And press "Integrate" within the main menu
    And follow "Webhooks" within the main menu
    Then the current page is the new webhook page

  Scenario: Creating a webhook
    Given they go to the new webhook page
    And there shouldn't be a button to "Ping!"
    When the form is submitted with:
      | URL | http://3scale-test.org |
    Then they should see the flash message "Webhooks settings were successfully updated."
    And there should be a button to "Ping!"
    And the current page is the edit webhooks page

  Scenario: Webhooks switch is denied
    Given the provider has "web_hooks" switch denied
    When they go to the new webhook page
    Then they should see "Access denied"

  @onpremises
  Scenario: Account plan changed event is hidden when on premises
    Given master admin is logged in
    When they go to the new webhook page
    Then there is no field "Account Plan changed"

  Scenario: Account plan changed event is visible normally
    Given master admin is logged in
    When they go to the new webhook page
    Then there is a field "Account Plan changed"
