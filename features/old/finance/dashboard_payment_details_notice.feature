@wip @3D
Feature: Notice about payment details on buyer dashboard
  In order to know if I have to provide my payment details
  As a buyer
  I want to see this information on my dashboard

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has default service and account plan

  Scenario: On free plan
    Given an application plan "Basic" of provider "foo.example.com"
    And plan "Basic" has monthly fee of 0
    And there is no user with username "bob"
    When the current domain is foo.example.com
    And I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"
    When user "bob" activates himself
    And buyer "bob" is approved
    And I log in as "bob" on foo.example.com
    And I go to the dashboard
    Then I should not see "Payment details required"

  Scenario: On paid plan
    Given provider "foo.example.com" is charging
    And an application plan "Pro" of provider "foo.example.com"
    And plan "Pro" has monthly fee of 200
    When the current domain is foo.example.com

    And I go to the sign up page for the "Pro" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    When user "bob" activates himself
    And buyer "bob" is approved
    And I log in as "bob" on foo.example.com
    And I go to the dashboard
    Then I should see "Payment details required"

  Scenario: On paid plan with trial period
    Given provider "foo.example.com" is charging
    And an application plan "Pro" of provider "foo.example.com"
    And plan "Pro" has monthly fee of 200
    And plan "Pro" has trial period of 30 days
    When the current domain is foo.example.com

    When I go to the sign up page for the "Pro" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"
    When user "bob" activates himself
    And buyer "bob" is approved
    And I log in as "bob" on foo.example.com
    And I go to the dashboard
    Then I should not see "Payment details required"

    And I should see "Trial period"
    And I should see "30 days remaining"

    When 12 days pass
    And I go to the dashboard
    Then I should see "18 days remaining"

  @wip @buyer_change_plan
  Scenario: On free plan, then upgrade to paid plan with trial period
    Given a provider "foo.example.com" is charging

    Given an application plan "Basic" of provider "foo.example.com"
    And plan "Basic" has monthly fee of 0
 
    And an application plan "Pro" of provider "foo.example.com"
    And plan "Pro" has monthly fee of 200
    And plan "Pro" has trial period of 30 days

    When the current domain is foo.example.com

    # Isolate to one step - signup
    And I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    And user "bob" activates himself
    And buyer "bob" is approved

    And I log in as "bob" on foo.example.com
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
    Given a provider "foo.example.com" with postpaid billing enabled
      And the date is March 1, 2003

    And an application plan "Basic" of provider "foo.example.com"
    And plan "Basic" has monthly fee of 100
    And plan "Basic" has trial period of 30 days

    And an application plan "Pro" of provider "foo.example.com"
    And plan "Pro" has monthly fee of 200
    And plan "Pro" has trial period of 30 days

    When the current domain is foo.example.com
    When I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    And user "bob" activates himself
    And buyer "bob" is approved

    And I log in as "bob" on foo.example.com
    And I go to the dashboard
    Then I should see "30 days remaining"

    When 10 days pass
    And buyer "bob" upgrades to plan "Pro"
    And I go to the dashboard
    Then I should see "20 days remaining"

  Scenario: On paid plan when payment gateway is in test mode
    Given a provider "foo.example.com" with postpaid billing enabled
    And provider "foo.example.com" has payment gateway in test mode
    And an application plan "Basic" of provider "foo.example.com"
    And plan "Basic" has monthly fee of 100
    When the current domain is foo.example.com
    And I go to the sign up page for the "Basic" plan
    And I fill in all required signup fields as "bob"
    And I press "Sign up"

    When user "bob" activates himself
    And buyer "bob" is approved

    And I log in as "bob" on foo.example.com
    And I go to the dashboard
    Then I should not see "Payment details required"
