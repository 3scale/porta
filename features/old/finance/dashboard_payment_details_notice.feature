@wip @3D
Feature: Notice about payment details on buyer dashboard
  In order to know if I have to provide my payment details
  As a buyer
  I want to see this information on my dashboard

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has default service and account plan
      And the default product of the provider has name "My API"

  Scenario: On free plan
    Given the following application plan:
      | Product | Name  | Cost per month |
      | My API  | Basic | 0              |
    And there is no user with username "bob"
    When the current domain is foo.3scale.localhost
    And I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"
    When user "bob" activates himself
    And buyer "bob" is approved
    And I log in as "bob" on foo.3scale.localhost
    And I go to the dashboard
    Then I should not see "Payment details required"

  Scenario: On paid plan
    Given provider "foo.3scale.localhost" is charging
    And the following application plan:
      | Product | Name | Cost per month |
      | My API  | Pro  | 200            |
    When the current domain is foo.3scale.localhost

    And I go to the sign up page for the "Pro" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    When user "bob" activates himself
    And buyer "bob" is approved
    And I log in as "bob" on foo.3scale.localhost
    And I go to the dashboard
    Then I should see "Payment details required"

  Scenario: On paid plan with trial period
    Given provider "foo.3scale.localhost" is charging
    And the following application plan:
      | Product | Name | Cost per month | Trial period |
      | My API  | Pro  | 200            | 30           |
    When the current domain is foo.3scale.localhost

    When I go to the sign up page for the "Pro" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"
    When user "bob" activates himself
    And buyer "bob" is approved
    And I log in as "bob" on foo.3scale.localhost
    And I go to the dashboard
    Then I should not see "Payment details required"

    And I should see "Trial period"
    And I should see "30 days remaining"

    When 12 days pass
    And I go to the dashboard
    Then I should see "18 days remaining"

  @wip @buyer_change_plan
  Scenario: On free plan, then upgrade to paid plan with trial period
    Given a provider "foo.3scale.localhost" is charging
    And the following application plans:
      | Product | Name  | Cost per month | Trial period |
      | My API  | Basic |                |              |
      | My API  | Pro   | 200            | 30           |

    When the current domain is foo.3scale.localhost

    # Isolate to one step - signup
    And I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    And user "bob" activates himself
    And buyer "bob" is approved

    And I log in as "bob" on foo.3scale.localhost
    And I go to the dashboard
    Then I should not see "Payment details required"
    And I should not see "Trial period"

    When 31 days pass
    And buyer "bob" upgrades to plan "Pro"
    And I go to the dashboard
    Then I should see "Payment details required"
    And I should not see "Trial period"

  @wip @buyer_change_plan
  Scenario: On paid plan with trial period, then upgrade to another paid plan with trial period
    Given a provider "foo.3scale.localhost" with postpaid billing enabled
      And the date is March 1, 2003
    And the following application plans:
      | Product | Name  | Cost per month | Trial period |
      | My API  | Basic | 100            | 30           |
      | My API  | Pro   | 200            | 30           |
    When the current domain is foo.3scale.localhost
    When I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    And user "bob" activates himself
    And buyer "bob" is approved

    And I log in as "bob" on foo.3scale.localhost
    And I go to the dashboard
    Then I should see "30 days remaining"

    When 10 days pass
    And buyer "bob" upgrades to plan "Pro"
    And I go to the dashboard
    Then I should see "20 days remaining"

  Scenario: On paid plan when payment gateway is in test mode
    Given a provider "foo.3scale.localhost" with postpaid billing enabled
    And provider "foo.3scale.localhost" has payment gateway in test mode
    And the following application plans:
      | Product | Name  | Cost per month |
      | My API  | Basic | 100            |
    When the current domain is foo.3scale.localhost
    And I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    When user "bob" activates himself
    And buyer "bob" is approved

    And I log in as "bob" on foo.3scale.localhost
    And I go to the dashboard
    Then I should not see "Payment details required"
