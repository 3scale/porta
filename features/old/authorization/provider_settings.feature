@javascript
Feature: Provider settings authorization
  In order to manage my settings
  As a provider
  I want to control who can access the settings area

  Background:
    Given a provider exists
    And the provider is charging its buyers
    And provider "foo.3scale.localhost" has Browser CMS activated

  Scenario: Provider admin can access settings
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    When I go to the provider dashboard
    Then there should be a link to "Billing" within the audience dashboard widget
    And there should be a link to "0 Accounts" within the audience dashboard widget
    And there should be a link to "Developer Portal" within the audience dashboard widget

  Scenario: Provider admin can access settings
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    Then they should be able to go to the following pages:
      | the edit site settings page       |
      | the finance settings page         |
      | the usage rules settings page     |
      | the fields definitions index page |
      | the emails settings page          |
      | the email templates page          |
      | the dns settings page             |
      | the bot protection page           |
      | the xss protection page           |
      | the authentication providers page |

  Scenario: Members per default cannot access settings
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" does not belong to the admin group "settings" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And I go to the provider dashboard
    Then there shouldn't be a link to "0 Accounts"
    And there shouldn't be a link to "Billing"
    And there shouldn't be a link to "Forum"
    And there shouldn't be a link to "0 Messages"
    And there shouldn't be a link to "Developer Portal"

  Scenario: Members per default cannot access settings
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" does not belong to the admin group "settings" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And they should see an error when going to the following pages:
      | the usage rules settings page     |
      | the fields definitions index page |
      | the edit site settings page       |
      | the finance settings page         |
      | the forum settings page           |
      | the emails settings page          |
      | the email templates page          |
      | the site settings page            |
      | the dns settings page             |
      | the bot protection page           |
      | the xss protection page           |
      | the authentication providers page |

  Scenario: Members of settings group can access settings
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "settings"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And I go to the provider dashboard
    And I follow "0 Messages"
    And they should be able to go to the following pages:
      | the usage rules settings page     |
      | the fields definitions index page |
      | the edit site settings page       |
      | the finance settings page         |
      | the emails settings page          |
      | the email templates page          |
      | the site settings page            |
      | the feature visibility page       |
      | the dns settings page             |
      | the bot protection page           |
      | the xss protection page           |
      | the authentication providers page |
