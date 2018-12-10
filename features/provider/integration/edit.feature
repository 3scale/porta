Feature: Edit Integration
  In order to integrate with 3scale
  As a provider
  I want to be able to edit the integration

  Background:
    Given a provider is logged in
     And all the rolling updates features are off

  Scenario: Edit a tested integration has a link to the analytics usage
    Given the service has been successfully tested
    When I go to the service integration page
     And I follow "the analytics section"
    Then I should be on the provider stats usage page

  # TODO: remove it when the Coffeescript is migrated to React
  @javascript
  Scenario: Changing the Authentication method should display the right curl command
    Given the service uses app_id/app_key as authentication method
    And I go to the service integration page
    And I toggle "Authentication Settings"
    When I choose "As HTTP Basic Authorization"
    Then The curl command uses Basic Authentication with app_id/app_key credentials
    When I choose "As query parameters (GET) or body parameters (POST/PUT/DELETE)"
    Then The curl command uses Query with app_id/app_key credentials
    When I choose "As HTTP Headers"
    Then The curl command uses Headers with app_id/app_key credentials
