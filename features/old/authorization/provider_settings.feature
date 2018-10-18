Feature: Provider settings authorization
  In order to manage my settings
  As a provider
  I want to control who can access the settings area

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has Browser CMS activated
      And provider "foo.example.com" has billing enabled

  Scenario Outline: Provider admin can access settings
     And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "foo.example.com"

    When I go to the provider dashboard

    Then I should see the link "<link>" in the audience dashboard widget
    And I follow "<link>"
    When I go to the <page> page
    Then I should be on the <page> page

    # not testing | Forum                | forum settings           |
    # as it doesn't appear on dashboard if 0 threads

    Examples:
      | link                 | page                     |
      | Billing              | edit site settings       |
      | Billing              | finance settings         |
      | Accounts             | usage rules settings     |
      | Accounts             | fields definitions index |
      | Messages             | emails settings          |
      | Messages             | email templates          |
      | Portal               | dns settings             |
      | Portal               | spam protection          |
      | Portal               | xss protection           |
      | Portal               | authentication providers |


  Scenario Outline: Members per default cannot access settings
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "settings" of provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
     And I go to the provider dashboard

    Then I should not see the link "<link>"
    When I request the url of the '<page>' page then I should see an exception

    Examples:
      | link                 | page                     |
      | Accounts             | usage rules settings     |
      | Accounts             | fields definitions index |
      | Billing              | edit site settings       |
      | Billing              | finance settings         |
      | Forum                | forum settings           |
      | Messages             | emails settings          |
      | Messages             | email templates          |
      | Portal               | site settings            |
      | Portal               | dns settings             |
      | Portal               | spam protection          |
      | Portal               | xss protection           |
      | Portal               | authentication providers |

  Scenario Outline: Members of settings group can access settings
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "settings"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "member"
      And I go to the provider dashboard

    Then I should see the link "Messages"
    And I follow "Messages"
    When I go to the <page> page
    Then I should be on the <page> page

    # not testing | Forum                | forum settings           |
    # as it doesn't appear on dashboard if 0 threads

    Examples:
      | link                 | page                     |
      | Accounts             | usage rules settings     |
      | Accounts             | fields definitions index |
      | Billing              | edit site settings       |
      | Billing              | finance settings         |
      | Messages             | emails settings          |
      | Messages             | email templates          |
      | Portal               | site settings            |
      | Portal               | feature visibility       |
      | Portal               | dns settings             |
      | Portal               | spam protection          |
      | Portal               | xss protection           |
      | Portal               | authentication providers |
