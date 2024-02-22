@javascript
Feature: Branding switch
  The value of the branding switch
  Controls the Branding feature

  Background:
    Given the default product of provider "master" has name "Master API"
    And the following application plan:
      | Product    | Name | State     |
      | Master API | Plus | Published |
    And a provider is logged in

  Scenario: Dns link invites to upgrade
    Given provider "foo.3scale.localhost" has "branding" switch denied
    And I go to the dns settings page
    And I follow "Change account subdomain"
    Then I should see the invitation to upgrade my plan

  Scenario: Dns link works if enabled
    Given provider "foo.3scale.localhost" has "branding" switch allowed
    And I go to the dns settings page
    And I follow "Change account subdomain"
    Then I should see "This operation can't be completed automatically"
