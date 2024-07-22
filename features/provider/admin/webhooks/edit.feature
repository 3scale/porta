@javascript @webhook
Feature: Provider webhooks

  As a provider, I want to define a URL to be called with a notification when events in the system
  happen.

  Background:
    Given a provider is logged in
    And the provider has "web_hooks" switch allowed
    And the provider has a webhook with endpoint "http://3scale-test.org"

  Scenario: Navigation
    Given they go to the provider dashboard
    When they select "Account Settings" from the context selector
    And press "Integrate" within the main menu
    And follow "Webhooks" within the main menu
    Then the current page is the edit webhooks page

  Scenario: Updating the webhook
    When they go to the edit webhooks page
    And the form is submitted with:
      | URL | http://example.com |
    Then they should see the flash message "Webhooks settings were successfully updated."

  Scenario: Testing the webhook enpoint
    When they go to the edit webhooks page
    And press "Ping!"
    Then they should see the flash message "http://3scale-test.org responded with 200"

  Scenario: Webhook endpoint is wrong
    Given the provider has a webhook with endpoint "http:://banana"
    When they go to the edit webhooks page
    And press "Ping!"
    Then they should see the flash message "Hostname not supplied: 'http:://banana'"

  Scenario: Webhooks switch is denied
    Given the provider has "web_hooks" switch denied
    When they go to the edit webhooks page
    Then they should see "Access denied"

  @onpremises
  Scenario: Account plan changed event is hidden when on premises
    Given master admin is logged in
    When they go to the edit webhooks page
    Then there is no field "Account Plan changed"

  Scenario: Account plan changed event is visible normally
    Given master admin is logged in
    When they go to the edit webhooks page
    Then there is a field "Account Plan changed"
