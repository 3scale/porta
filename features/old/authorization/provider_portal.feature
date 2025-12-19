@javascript
Feature: Provider portal section authorization
  In order to manage my portal
  As a provider
  I want to control who can access the portal area

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"

  Scenario: Provider admin can access portal
    When I log in as provider "foo.3scale.localhost"
    When I go to the provider dashboard
    Then there should be a link to "Developer Portal"
    Then they should be able to go to the following pages:
      | the CMS Templates page |

  Scenario: Provider admin can access portal groups
    When I log in as provider "foo.3scale.localhost"
    Then they should see an error when going to the groups page
    When provider "foo.3scale.localhost" has "groups" switch allowed
    Then they should be able to go to the groups page

  Scenario: Members by default cannot access portal
    Given an active user "member" of account "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And I go to the provider dashboard
    And there should not be a link to "Developer Portal"
    And they should see an error when going to the following pages:
      | the CMS Templates page |
      | the groups page        |

  Scenario: Members of portal group can not access portal groups area
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "portal"
    When I log in as provider "member"
    Then they should see an error when going to the groups page

  Scenario: Members of portal group can access portal
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "portal"
    When I log in as provider "member"
    And I go to the provider dashboard
    And there should be a link to "Developer Portal" within the audience dashboard widget
    Then they should be able to go to the following pages:
      | the CMS Templates page |
