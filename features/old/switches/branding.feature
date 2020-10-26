@javascript
Feature: Branding switch
  The value of the branding switch
  Controls the Branding feature

  Background:
    Given a published application plan "plus" of provider "master"
    And a provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"

  Scenario: Dns link invites to upgrade
    Given provider "foo.3scale.localhost" has "branding" switch denied
    When I log in as provider "foo.3scale.localhost"
     And I go to the dns settings page
     And I follow "Change"
    Then I should see the invitation to upgrade my plan

  Scenario: Dns link works if enabled
    Given provider "foo.3scale.localhost" has "branding" switch allowed
    When I log in as provider "foo.3scale.localhost"
     And I go to the dns settings page
     And I follow "Change"
     Then I should see "This operation can't be completed automatically"
