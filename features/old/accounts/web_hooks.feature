@javascript @webhook
Feature: Web Hook management
  I should be able to see, add and edit webhooks

  Background:
    Given a provider is logged in

  Scenario: Configure WebHooks when switch enabled
    And the provider has "web_hooks" switch allowed
    And I go to the edit webhooks page
    Then I should not see "Ping!"
    When I fill in "URL" with "http://google.com"
    And I press "Update"
    And I press "Ping!"
    Then I should see "'http://google.com' responded with"

  Scenario: In denied state, I should see link to upgrade warning
    And the provider has "web_hooks" switch denied
    And I go to the edit webhooks page
    Then I should see "Access denied"
