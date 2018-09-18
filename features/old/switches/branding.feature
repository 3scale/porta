Feature: Branding switch
  The value of the branding switch
  Controls the Branding feature

  Background:
    Given an application plan "plus" of provider "master"
    And a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"

  Scenario: Dns link invites to upgrade
    Given provider "foo.example.com" has "branding" switch denied
    When I log in as provider "foo.example.com"
     And I go to the dns settings page
     And I follow "Change"
    Then I should see the invitation to upgrade my plan

  @javascript
  Scenario: Dns link works if enabled
    Given provider "foo.example.com" has "branding" switch allowed
    When I log in as provider "foo.example.com"
     And I go to the dns settings page
     And I follow "Change"
     Then I should see "This operation can't be completed automatically"
