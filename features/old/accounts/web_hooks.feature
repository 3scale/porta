@javascript @webhook

Feature: Web Hook management
  I should be able to see, add and edit webhooks

  Background:
    Given a provider "foo.example.com"
    Given current domain is the admin domain of provider "foo.example.com"

  Scenario: Configure WebHooks when switch enabled
    When I log in as provider "foo.example.com"
      And provider "foo.example.com" has "web_hooks" switch allowed
    And I follow "Settings"
    And I follow "Webhooks"
    Then I should not see "Ping!"
    When I fill in "URL" with "http://google.com"
    And I press "Update"

    And I press "Ping!"
    Then I should see "'http://google.com' responded with"

  Scenario: In denied state, I should see link to upgrade warning
    When I log in as provider "foo.example.com"
      And I follow "Settings"
      And I follow "Webhooks"
    Then I should be on the upgrade notice page for "web_hooks"
