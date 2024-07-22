@javascript
Feature: Provider finance authorization
  In order to manage my finance
  As a provider
  I want to control who can access the finance area

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has Browser CMS activated
    And provider "foo.3scale.localhost" has "finance" allowed

  Scenario: Provider admin can access finance
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"
    When I go to the provider dashboard
    Then I should see "Billing" within the audience dashboard widget
    And they should be able to go to the following pages:
      | the earnings by month page          |
      | the finance settings page |

  Scenario: Members per default cannot access finance
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" does not belong to the admin group "finance" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And I go to the provider dashboard
    Then I should not see "Billing" within the audience dashboard widget
    And they should see an error when going to the following pages:
      | the earnings by month page          |
      | the finance settings page |

  Scenario: Members of finance group can access finance
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "finance"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And I go to the provider dashboard
    Then I should see "Billing" within the audience dashboard widget
    And they should be able to go to the following pages:
      | the earnings by month page          |
      | the finance settings page |
