Feature: Buyer's service subscription
  In order to use some API when in multiservice settings
  As buyer
  I want to be able to subscribe to a service

  Background:
    Given all the rolling updates features are off
    Given a provider "foo.3scale.localhost"

    And provider "foo.3scale.localhost" has "multiple_services" visible
    And a service "Second" of provider "foo.3scale.localhost"
    And a buyer "bob" of provider "foo.3scale.localhost"
    And the default product of the provider has name "My API"
    And the following service plan:
      | Product | Name       | State     |
      | My API  | SoundsLike | Published |
    And I log in as "bob" on foo.3scale.localhost

  Scenario: Simple subscription
    And the following service plan:
      | Product | Name       | State     |
      | My API  | AnotherOne | Published |
     And I go to the service subscription page
     And I press "Subscribe"
    Then I should see "You have successfully subscribed to a service."

  Scenario: Subscription with approval
    Given the following service plan:
      | Product | Name     | State     | Requires approval |
      | Second  | Platinum | Published | true              |

    When I go to the service subscription page
     And I select "Platinum" from "Plan"
     And press "Subscribe"
    Then I should see "You have successfully subscribed to a service."
     And I should see "Platinum (pending)"

  Scenario: Subscribe with legal terms
    Given provider "foo.3scale.localhost" has service subscription legal terms:
     """
     <h1>Magna Charta Libertatum</h1>
     <p>All your base are belong to us.</p>
     """
    And the following service plan:
      | Product | Name | State     |
      | Second  | Cool | Published |

    When I go to the service subscription page
    Then I should see "Magna Charta"
     And I press "Subscribe"
    Then I should see "You have successfully subscribed to a service."

  Scenario: Fast lane - automatically subscribed when there is no plan to choose from
    When I log in as "bob" on foo.3scale.localhost
     And I go to the service subscription page
    Then I should see "You have successfully subscribed to a service."
