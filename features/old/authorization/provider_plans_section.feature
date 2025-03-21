@javascript
Feature: Admin portal plans section authorization

  # TODO: should this be an integration test instead?

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "service_plans" visible
    And a product "Zoo API"
    And a backend "Zoo Backend"
    And the following account plan:
      | Issuer               | Name         |
      | foo.3scale.localhost | account plan |
    And the following application plan:
      | Issuer  | Name     |
      | Zoo API | app plan |
    And the following service plan:
      | Issuer  | Name      |
      | Zoo API | serv plan |

  Scenario: Provider admin can access plans
    Given an admin "admin" of the provider
    When I log in as provider "admin"
    And they go to the provider dashboard
    Then should see "Zoo API" within the apis dashboard widget
    And should see "Zoo Backend" within the apis dashboard widget
    And they should be able to go to the following pages:
      | API dashboard                              |
      | the account plans admin page               |
      | the product's application plans admin page |
      | the service plans admin page               |
      | plan "account plan" admin edit page        |
      | plan "serv plan" admin edit page           |
      | plan "app plan" admin edit page            |

  Scenario: Members per default cannot access plans
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" does not belong to the admin group "plans" of provider "foo.3scale.localhost"
    When I log in as provider "member"
    And they go to the provider dashboard
    Then should not see "Zoo API" within the apis dashboard widget
    And should not see "Zoo Backend" within the apis dashboard widget
    And they should see an error when going to the following pages:
      | the API dashboard                          |
      | the account plans admin page               |
      | the product's application plans admin page |
      | the service plans admin page               |
      | plan "account plan" admin edit page        |
      | plan "serv plan" admin edit page           |
      | plan "app plan" admin edit page            |

  Scenario: Members of plans group can access plans
    Given an active user "member" of account "foo.3scale.localhost"
    And user "member" has access to the admin section "plans"
    When I log in as provider "member"
    And they go to the provider dashboard
    Then should see "Zoo API" within the apis dashboard widget
    And should see "Zoo Backend" within the apis dashboard widget
    And they should be able to go to the following pages:
      | the API dashboard                          |
      | the account plans admin page               |
      | the product's application plans admin page |
      | the service plans admin page               |
      | plan "account plan" admin edit page        |
      | plan "serv plan" admin edit page           |
      | plan "app plan" admin edit page            |
