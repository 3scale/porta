Feature: Provider settings authorization
  In order to manage my settings
  As a provider
  I want to control who can access the settings area

  Background:
    Given a provider exists
      And the provider is charging its buyers
      And provider "foo.3scale.localhost" has Browser CMS activated

  Scenario Outline: Provider admin can access settings
    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"
     When I go to the provider dashboard
      And I follow "<link>" within the audience dashboard widget
      And I go to the <page> page
     Then I should be on the <page> page

    # not testing | Forum                | forum settings           |
    # as it doesn't appear on dashboard if 0 threads

    Examples:
      | link                 | page                     |
      | Billing              | edit site settings       |
      | Billing              | finance settings         |
      | 0 Accounts           | usage rules settings     |
      | 0 Accounts           | fields definitions index |
      | 0 Messages           | emails settings          |
      | 0 Messages           | email templates          |
      | Developer Portal     | dns settings             |
      | Developer Portal     | spam protection          |
      | Developer Portal     | xss protection           |
      | Developer Portal     | authentication providers |


  Scenario Outline: Members per default cannot access settings
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" does not belong to the admin group "settings" of provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
     When I log in as provider "member"
     And I go to the provider dashboard

    Then I should not see the link "<link>"
    When I request the url of the '<page>' page then I should see an exception

    Examples:
      | link                 | page                     |
      | 0 Accounts           | usage rules settings     |
      | 0 Accounts           | fields definitions index |
      | Billing              | edit site settings       |
      | Billing              | finance settings         |
      | Forum                | forum settings           |
      | 0 Messages           | emails settings          |
      | 0 Messages           | email templates          |
      | Developer Portal     | site settings            |
      | Developer Portal     | dns settings             |
      | Developer Portal     | spam protection          |
      | Developer Portal     | xss protection           |
      | Developer Portal     | authentication providers |

  Scenario Outline: Members of settings group can access settings
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" has access to the admin section "settings"
      And current domain is the admin domain of provider "foo.3scale.localhost"
     When I log in as provider "member"
      And I go to the provider dashboard
      And I follow "0 Messages"
      And I go to the <page> page
     Then I should be on the <page> page

    # not testing | Forum                | forum settings           |
    # as it doesn't appear on dashboard if 0 threads

    Examples:
      | link                 | page                     |
      | 0 Accounts           | usage rules settings     |
      | 0 Accounts           | fields definitions index |
      | Billing              | edit site settings       |
      | Billing              | finance settings         |
      | 0 Messages           | emails settings          |
      | 0 Messages           | email templates          |
      | Developer Portal     | site settings            |
      | Developer Portal     | feature visibility       |
      | Developer Portal     | dns settings             |
      | Developer Portal     | spam protection          |
      | Developer Portal     | xss protection           |
      | Developer Portal     | authentication providers |
