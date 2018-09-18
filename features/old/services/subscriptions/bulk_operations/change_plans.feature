@javascript
Feature: Bulk operations
  In order to transfer service subscriptions from one plan to another
  As a provider
  I want to change service contracts' plans in bulk

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "service_plans" visible
      And a default service of provider "foo.example.com" has name "Fancy API"
      And a service "New Service" of provider "foo.example.com"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.example.com":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"

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


    Then I should see following table:
      | Account ▲ | Plan        |
      | bob       | Basic       |
      | bob       | Unpublished |
      | jane      | Basic       |
      | mike      | Awesome     |

  @wip
  Scenario: Try to mass change contracts from different services
    # TODO: !

