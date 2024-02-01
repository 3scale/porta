@javascript
Feature: Provider stats section authorization
  In order to manage my stats
  As a provider
  I want to control who can access the stats area

  Background:
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" has Browser CMS activated
    And all the rolling updates features are off

  Scenario: Provider admin can access stats
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"
    When I go to the provider dashboard
    And I follow "API"
    Then I should see "Analytics" within the main menu
    And they should be able to go to the following pages:
      | the provider stats usage page |
      | the provider stats apps page  |
      | the provider stats days page  |
      | the provider stats hours page |

  Scenario: Members per default cannot access stats
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" does not belong to the admin group "monitoring" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And I go to the provider dashboard
    Then I should not see the link "Analytics" within the apis dashboard widget
    And they should see an error when going to the following pages:
      | the provider stats usage page |
      | the provider stats apps page  |
      | the provider stats days page  |
      | the provider stats hours page |

  Scenario: Members of stats group can access stats
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "monitoring"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And I go to the provider dashboard
    When I follow "API"
    Then I should see "Analytics" within the main menu
    And they should be able to go to the following pages:
      | the provider stats usage page |
      | the provider stats apps page  |
      | the provider stats days page  |
      | the provider stats hours page |
