@javascript
Feature: Bulk operations
  In order to transfer service subscriptions from one plan to another
  As a provider
  I want to change service contracts' plans in bulk

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "service_plans" visible
      And a default service of provider "foo.3scale.localhost" has name "Fancy API"
      And a service "New Service" of provider "foo.3scale.localhost"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.3scale.localhost":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I am logged in as provider "foo.3scale.localhost"

  Scenario: No plan is selected
    Given a service plan "Awesome" of service "New Service"
    And I am on the service contracts admin page
    When I check select for "mike"
    And I press "Change service plan"
    And I press "Change plan" and I confirm dialog box
    Then I should see "Required parameter missing: plan_id"

  Scenario: Mass change of service contracts' plans
    Given a service plan "Awesome" of service "New Service"
      And I am on the service contracts admin page

    When I follow "Account" within table
    When I check select for "mike"
      And I press "Change service plan"

    Then I should see "Transfer these subscriptions to different service plan"

    When I select "Awesome" from "Plan"
      And I press "Change plan" and I confirm dialog box

    Then I should see "Action completed successfully"

    When I go to the service contracts admin page
     And I follow "Account" within table


    Then I should see following table:
      | Account ▲ | Plan        |
      | bob       | Basic       |
      | bob       | Unpublished |
      | jane      | Basic       |
      | mike      | Awesome     |

  @wip
  Scenario: Try to mass change contracts from different services
    # TODO: !

  Scenario: Error template shows correctly
    And I am on the service contracts admin page
    When I follow "Account" within table
    When I check select for "jane"
    And I press "Change service plan"
    When I select "Default" from "Plan"
    Given the subscription will return an error when plan changed
    And I press "Change plan" and I confirm dialog box
    Then I should see the bulk action failed with service subscription of account "jane"
